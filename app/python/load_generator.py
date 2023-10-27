import asyncio
import logging
from random import randint

from db import Redis

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

redis = Redis()


async def playground(redis_: Redis):
    # pylint: disable=global-statement
    count, success, fail = 0, 0, 0
    while True:
        count += 1
        key = f"foo-{randint(0, 10000)}"
        value = f"foo-{randint(0, 10000)}"
        try:
            _ = await redis_.set(f"test:{key}", value)
            success += 1
        except Exception:
            fail += 1
            logger.error("[ERROR] set %s %s", key, value)
        await asyncio.sleep(0.1)
        try:
            _ = await redis_.get(f"test:{key}")
            success += 1
        except Exception:
            fail += 1
            logger.error("[ERROR] get %s", key)
        await asyncio.sleep(0.1)
        if count % 100 == 0:
            logger.info(
                "[PROGRESS] %s success, %s fail -> rate %s",
                success,
                fail,
                success / (success + fail),
            )


async def main():
    await redis.initialize()
    await playground(redis)
    await redis.destroy()


if __name__ == "__main__":
    asyncio.run(main())
