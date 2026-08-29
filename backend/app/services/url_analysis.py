from urllib.parse import urlparse


SHORTENERS = {
    "bit.ly",
    "tinyurl.com",
    "t.co",
    "goo.gl",
    "ow.ly",
    "is.gd",
    "buff.ly",
    "cutt.ly",
    "rebrand.ly",
    "shorturl.at",
}


def analyze_url(url: str) -> dict:
    raw = url.strip()
    parsed = urlparse(raw)

    valid = parsed.scheme in {"http", "https"} and bool(parsed.netloc)

    host = (parsed.hostname or "").lower()
    scheme = parsed.scheme.lower() if parsed.scheme else None

    is_https = scheme == "https"
    is_long = len(raw) > 40

    is_shortener = (
        host in SHORTENERS
        or any(host.endswith(f".{domain}") for domain in SHORTENERS)
    )

    has_username = bool(parsed.username)

    try:
        port = parsed.port
    except ValueError:
        port = None

    has_non_default_port = (
        port is not None
        and (
            (scheme == "http" and port != 80)
            or (scheme == "https" and port != 443)
            or scheme not in {"http", "https"}
        )
    )

    indicators: list[str] = []

    if not valid:
        indicators.append("URL format could not be validated")
    else:
        indicators.append(f"Host: {host}")

        if is_https:
            indicators.append("HTTPS enabled: encrypted transport is indicated")
        else:
            indicators.append(
                "HTTP URL: encrypted transport is not indicated"
            )

        if is_long:
            indicators.append("Long URL detected")

        if is_shortener:
            indicators.append("Known URL shortener detected")

        if has_username:
            indicators.append(
                "URL contains embedded user information before the host"
            )

        if has_non_default_port and port is not None:
            indicators.append(
                f"Non-default port detected: {port}"
            )

    return {
        "url": raw,
        "valid": valid,
        "scheme": scheme,
        "host": host or None,
        "is_https": is_https,
        "is_shortener": is_shortener,
        "has_username": has_username,
        "has_non_default_port": has_non_default_port,
        "is_long": is_long,
        "indicators": indicators,
    }