from pydantic import BaseModel, Field, ConfigDict
from ..core.config import MAX_URL_LENGTH


class UrlAnalysisRequest(BaseModel):
    model_config = ConfigDict(str_strip_whitespace=True)
    url: str = Field(..., min_length=1, max_length=MAX_URL_LENGTH)


class UrlAnalysisResponse(BaseModel):
    url: str
    valid: bool
    scheme: str | None = None
    host: str | None = None
    is_https: bool
    is_shortener: bool
    has_username: bool
    has_non_default_port: bool
    is_long: bool
    indicators: list[str]
