import time
from collections import defaultdict, deque
from threading import Lock

from fastapi import Request
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware

from ..core.config import (
    AUTH_RATE_LIMIT_MAX_REQUESTS,
    MAX_REQUEST_BODY_BYTES,
    RATE_LIMIT_MAX_REQUESTS,
    RATE_LIMIT_WINDOW_SECONDS,
)


class RequestSizeLimitMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        content_length = request.headers.get("content-length")
        if content_length:
            try:
                if int(content_length) > MAX_REQUEST_BODY_BYTES:
                    return JSONResponse(status_code=413, content={"detail": "Request body is too large"})
            except ValueError:
                return JSONResponse(status_code=400, content={"detail": "Invalid Content-Length header"})
        return await call_next(request)


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Referrer-Policy"] = "no-referrer"
        response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
        response.headers["Cache-Control"] = "no-store"
        return response


class InMemoryRateLimitMiddleware(BaseHTTPMiddleware):
    """Lightweight single-instance limiter for development/small deployments.

    For multi-worker production deployments, replace this with a shared store
    such as Redis so limits are enforced consistently across workers.
    """

    def __init__(self, app):
        super().__init__(app)
        self._lock = Lock()
        self._requests = defaultdict(deque)

    @staticmethod
    def _client_key(request: Request) -> str:
        forwarded = request.headers.get("x-forwarded-for")
        if forwarded:
            return forwarded.split(",")[0].strip()
        return request.client.host if request.client else "unknown"

    def _allowed(self, key: str, limit: int) -> bool:
        now = time.monotonic()
        cutoff = now - RATE_LIMIT_WINDOW_SECONDS
        with self._lock:
            bucket = self._requests[(key, limit)]
            while bucket and bucket[0] <= cutoff:
                bucket.popleft()
            if len(bucket) >= limit:
                return False
            bucket.append(now)
            return True

    async def dispatch(self, request: Request, call_next):
        if request.url.path.startswith("/api/auth/"):
            limit = AUTH_RATE_LIMIT_MAX_REQUESTS
        elif request.url.path.startswith("/api/"):
            limit = RATE_LIMIT_MAX_REQUESTS
        else:
            return await call_next(request)

        key = self._client_key(request)
        if not self._allowed(key, limit):
            return JSONResponse(
                status_code=429,
                content={"detail": "Too many requests. Please try again later."},
                headers={"Retry-After": str(RATE_LIMIT_WINDOW_SECONDS)},
            )
        return await call_next(request)
