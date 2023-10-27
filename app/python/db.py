import logging

from redis.asyncio.client import Redis as RedisClient
from redis.asyncio.client import StrictRedis
from redis.asyncio.cluster import ClusterNode, RedisCluster
from redis.asyncio.retry import Retry
from redis.asyncio.sentinel import (
    MasterNotFoundError,
    Sentinel,
    SentinelConnectionPool,
    SlaveNotFoundError,
)
from redis.backoff import ExponentialBackoff
from redis.exceptions import BusyLoadingError
from redis.exceptions import ConnectionError as RedisConnectionError
from redis.exceptions import ResponseError as RedisResponseError
from redis.exceptions import TimeoutError as RedisTimeoutError

from settings import RedisModeTypes, settings


class Redis:
    redis: RedisClient
    redis_addrs: list[str]

    def __init__(self):
        self.redis = None
        self.redis_addrs = None

    async def _initialize_cluster(self) -> bool:
        redis_addrs = self.redis_addrs
        addrs = [addr.strip().replace("redis://", "") for addr in redis_addrs]
        host_port_list = []
        for addr in addrs:
            host, port = addr.split(":")
            host_port_list.append((host, int(port)))

        startup_nodes = [
            ClusterNode(host=host, port=port) for host, port in host_port_list
        ]
        self.redis = RedisCluster(
            startup_nodes=startup_nodes,
            username=settings.redis_username,
            password=settings.redis_password,
            decode_responses=True,
            retry=Retry(
                ExponentialBackoff(),
                3,
            ),
            retry_on_error=[
                RedisConnectionError,
                RedisTimeoutError,
                BusyLoadingError,
            ],
            encoding="utf-8",
            max_connections=settings.redis_max_connections,
        )
        try:
            await self.redis.ping()
            logging.info("Redis cluster connection established")
            return True
        except RedisResponseError:
            logging.error("Redis cluster connection failed")
        return False

    async def _initialize_sentinel(self) -> bool:
        redis_sentinel_name = settings.redis_sentinel_name
        redis_addrs = self.redis_addrs
        addrs = [addr.strip().replace("redis://", "") for addr in redis_addrs]
        host_port_list = []
        for addr in addrs:
            host, port = addr.split(":")
            host_port_list.append((host, int(port)))
        sentinel_manager = Sentinel(
            sentinels=host_port_list,
            socket_timeout=1,
        )
        try:
            master = await sentinel_manager.discover_master(redis_sentinel_name)
            logging.warning("master >> %s", master)
        except (MasterNotFoundError, RedisResponseError):
            logging.warning("Sentinel master not found")
            return False
        logging.info("Sentinel master found >> %s", master)
        try:
            slave = await sentinel_manager.discover_slaves(redis_sentinel_name)
        except (SlaveNotFoundError, RedisResponseError):
            logging.warning("Sentinel slaves not found")
            return False
        logging.info("Sentinel slaves found >> %s", slave)
        pool = SentinelConnectionPool(
            sentinel_manager=sentinel_manager,
            service_name=redis_sentinel_name,
            socket_timeout=1,
            username=settings.redis_username,
            password=settings.redis_password,
            db=settings.redis_db_index,
            max_connections=settings.redis_max_connections,
            encoding="utf-8",
            decode_responses=True,
        )
        redis = StrictRedis(connection_pool=pool)
        try:
            await redis.ping()
            logging.info("Redis sentinel connection established")
            self.redis = redis
            return True
        except RedisResponseError:
            logging.error("Redis sentinel connection failed")
        return False

    async def _initialize_replica(self) -> bool:
        redis_addrs = self.redis_addrs
        if isinstance(redis_addrs, str):
            redis_addrs = [redis_addrs]
        redis = StrictRedis.from_url(
            url=redis_addrs[0],
            username=settings.redis_username,
            password=settings.redis_password,
            db=settings.redis_db_index,
            max_connections=settings.redis_max_connections,
            encoding="utf-8",
            decode_responses=True,
        )
        try:
            await redis.ping()
            logging.info("Redis replica connection established")
            self.redis = redis
            return True
        except RedisResponseError:
            logging.error("Redis replica connection failed")
        return False

    async def initialize(self):
        connected = False
        redis_addrs = settings.redis_addrs.split(",")
        if isinstance(redis_addrs, str):
            redis_addrs = [redis_addrs]
        self.redis_addrs = [addr.strip() for addr in redis_addrs]

        if settings.redis_mode == RedisModeTypes.cluster:
            connected = await self._initialize_cluster()
        elif settings.redis_mode == RedisModeTypes.sentinel:
            connected = await self._initialize_sentinel()
        elif settings.redis_mode == RedisModeTypes.replica:
            connected = await self._initialize_replica()
        elif settings.redis_mode == RedisModeTypes.auto:
            connected = await self._initialize_cluster()
            if not connected:
                connected = await self._initialize_sentinel()
            if not connected:
                connected = await self._initialize_replica()
        else:
            raise ValueError(f"Invalid redis mode: {settings.redis_mode}")
        if not connected:
            raise RedisConnectionError

    async def get(self, key: str) -> str:
        return await self.redis.get(key)

    async def set(self, key: str, value: str) -> bool:
        return await self.redis.set(key, value)

    async def delete(self, key: str) -> bool:
        return await self.redis.delete(key)

    async def exists(self, key: str) -> bool:
        return await self.redis.exists(key)

    async def expire(self, key: str, seconds: int) -> bool:
        return await self.redis.expire(key, seconds)

    async def ttl(self, key: str) -> int:
        return await self.redis.ttl(key)

    async def scan(self, match: str) -> list[str]:
        return self.redis.scan_iter(match=match, count=1000)

    async def keys(self, match: str) -> list[str]:
        logging.warning("KEYS cause performance issue, use SCAN instead")
        return self.scan(match=match)

    async def execute_command(self, *args, **options):
        return await self.redis.execute_command(*args, **options)

    async def destroy(self):
        await self.redis.aclose()
        logging.info("Redis connection closed")
