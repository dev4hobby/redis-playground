import pytest
from db import Redis

@pytest.fixture
async def redis():
    redis_ = Redis()
    await redis_.initialize()
    yield redis_
    await redis_.destroy()
