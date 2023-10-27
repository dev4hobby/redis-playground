from enum import Enum
from functools import lru_cache
from typing import Optional

from pydantic_settings import BaseSettings


class RedisModeTypes(str, Enum):
    cluster = "cluster"
    sentinel = "sentinel"
    replica = "replica"
    auto = "auto"


class Settings(BaseSettings):
    # Database
    redis_addrs: str = None
    redis_mode: RedisModeTypes = "auto"
    redis_username: str = "default"
    redis_password: str
    redis_sentinel_name: Optional[str] = None
    redis_max_connections: int = 1000
    redis_db_index: int = 0
    # Logging
    logging_level: str = "INFO"
    logging_format: str = (
        "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    )


@lru_cache
def get_settings():
    return Settings()


settings = get_settings()
