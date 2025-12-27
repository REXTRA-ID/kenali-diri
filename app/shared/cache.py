import redis
import json
from app.core.config import settings

redis_client = redis.from_url(settings.REDIS_URL, decode_responses=True)

def cache_get(key: str):
    """Get value dari Redis"""
    value = redis_client.get(key)
    return json.loads(value) if value else None

def cache_set(key: str, value: dict, ttl: int = 3600):
    """Set value ke Redis dengan TTL"""
    redis_client.setex(key, ttl, json.dumps(value))

def cache_delete(key: str):
    """Delete key dari Redis"""
    redis_client.delete(key)