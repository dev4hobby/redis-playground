from db import Redis

async def test_basic_commands(redis: Redis):
    assert await redis.set("test:foo", "bar") is True
    assert await redis.get("test:foo") == "bar"
    assert await redis.set("test:foo", "baz") is True
    assert await redis.exists("test:foo") == 1
    assert await redis.delete("test:foo") == 1
    assert await redis.exists("test:foo") == 0
    assert await redis.get("test:foo") is None
    assert await redis.delete("test:foo") == 0
    assert await redis.set("test:foo", "bar") is True
    assert await redis.ttl("test:foo") == -1
    assert await redis.expire("test:foo", 10) is True
    assert await redis.ttl("test:foo") == 10
    assert await redis.expire("test:foo", 0) is True
    assert await redis.ttl("test:foo") == -2
    assert await redis.delete("test:foo") is 0
    assert await redis.ttl("test:foo") == -2
    assert await redis.expire("test:foo", 10) is False
    assert await redis.ttl("test:foo") == -2

async def test_execute_command(redis: Redis):
    assert await redis.execute_command("SET", "test:foo", "bar") is True
    assert await redis.execute_command("GET", "test:foo") == "bar"
    assert await redis.execute_command("DEL", "test:foo") is 1
    assert await redis.execute_command("GET", "test:foo") is None
    assert await redis.execute_command("DEL", "test:foo") is 0
    assert await redis.execute_command("SET", "test:foo", "bar") is True
    assert await redis.execute_command("TTL", "test:foo") == -1
    assert await redis.execute_command("EXPIRE", "test:foo", 10) is True
    assert await redis.execute_command("TTL", "test:foo") == 10
    assert await redis.execute_command("EXPIRE", "test:foo", 0) is True
    assert await redis.execute_command("TTL", "test:foo") == -2
    assert await redis.execute_command("DEL", "test:foo") is 0
    assert await redis.execute_command("TTL", "test:foo") == -2
    assert await redis.execute_command("EXPIRE", "test:foo", 10) is False
    assert await redis.execute_command("TTL", "test:foo") == -2
