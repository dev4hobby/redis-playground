import ioredis from "ioredis"

const redisAddrs = process.env.REDIS_ADDRS.split(",")
const redisMode = process.env.REDIS_MODE ?? "cluster"
const redisSentinelName= process.env.REDIS_SENTINEL_NAME
const redisUsername = process.env.REDIS_USER
const redisPassword = process.env.REDIS_PASSWORD
const redisMaxConnections = process.env.REDIS_MAX_CONNECTIONS ?? 1000
const redisDBIndex = process.env.REDIS_DB_INDEX ?? 0

const getHostAndPortArray = (redisAddrs) => {
  if (typeof(redisAddrs) === "string") {
    const [host, port] = redisAddrs.replace("redis://", "").split(":")
    return [{ host, port }]
  } else {
    return redisAddrs.map(addr => {
      const [host, port] = addr.replace("redis://", "").split(":")
      return { host, port }
    })
  }
}

const connectToCluster = async () => {
  const startupNodes = getHostAndPortArray(redisAddrs)
  return new ioredis.Cluster(startupNodes, {
    redisOptions: {
      username: redisUsername,
      password: redisPassword,
      maxConnections: redisMaxConnections,
      db: redisDBIndex,
    },
  })
}

const connectToSentinel = async () => {
  const sentinels = getHostAndPortArray(redisAddrs)
  return new ioredis({
    sentinels: sentinels,
    name: redisSentinelName,
    username: redisUsername,
    password: redisPassword,
    maxConnections: redisMaxConnections,
    db: redisDBIndex,
  })
}

const connectToReplica = async () => {
  const hostAndPortArray = getHostAndPortArray(redisAddrs)
  const hostAndPort = hostAndPortArray[0]
  const host = hostAndPort.host
  const port = parseInt(hostAndPort.port)
  return new ioredis({
    host: host,
    port: port,
    username: redisUsername,
    password: redisPassword,
    maxConnections: redisMaxConnections,
    db: redisDBIndex,
  })
}


export const getRedisClient = async () => {
  if (redisMode === "cluster") {
    console.log("Connecting to redis cluster")
    return await connectToCluster()
  } else if (redisMode === "sentinel") {
    console.log("Connecting to redis sentinel")
    return await connectToSentinel()
  } else if (redisMode === "replica") {
    console.log("Connecting to redis replica")
    return await connectToReplica()
  } else {
    throw new Error("invalid redis mode")
  }
}

export const bulkInsert = async (count) => {
  const redis = await getRedisClient()
  const start = Date.now()
  for (let i = 0; i < count; i++) {
    await redis.set(`foo${i}`, `bar${i}`)
  }
  const end = Date.now()
  console.log(`inserted ${count} keys in ${end - start}ms`)
}

export const bulkRead = async (count) => {
  const redis = await getRedisClient()
  const start = Date.now()
  for (let i = 0; i < count; i++) {
    await redis.get(`foo${i}`)
  }
  const end = Date.now()
  console.log(`read ${count} keys in ${end - start}ms`)
}

export const bulk = async (count) => {
  const redis = await getRedisClient()
  const start = Date.now()
  for (let i = 0; i < count; i++) {
    await redis.set(`foo${i}`, `bar${i}`)
    await redis.get(`foo${i}`)
  }
  const end = Date.now()
  console.log(`read and write ${count} keys in ${end - start}ms`)
}
