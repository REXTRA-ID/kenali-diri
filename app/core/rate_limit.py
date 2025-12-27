from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["100/minute"],
    storage_uri="redis://localhost:6379/3"
)

def rate_limit_exceeded_handler(request, exc):
    return {
        "error": "rate_limit_exceeded",
        "message": "Too many requests. Please try again later."
    }