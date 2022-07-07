# Redis Cluster Playground

## Commands

```bash
make help

clustering           Run the clustering script.
help                 Show this help message.
inspect-redis        Inspect the redis container.
io-example           Run the io-example script.
run-redis            Run all redis container via docker-compose.
```

## Usage

```bash
make run-redis
```

![image1](docs/1.gif)
after docker-compose run redis, you can check redis container are clustered.  
if you wanna know how container are clustered, [Check this out](https://github.com/dev4hobby/redis-cluster-playground/blob/main/docker-compose.yml#L72)

![image3](docs/3.png)

```bash
docker exec -it redis-master-1 bash -c "redis-cli -c -p 7001 set foo bar"
docker exec -it redis-master-1 bash -c "redis-cli -c -p 7003 get foo"

# or just..
make io-example
```

Redis container are clustered.

Done. Easy huh?
