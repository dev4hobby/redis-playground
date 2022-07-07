# How to clustering?

## Create cluster

```bash
# from host terminal
docker exec -it redis-master-1 bash
```

```bash
# from redis-master-1 (docker:7001)
redis-cli --cluster create 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 127.0.0.1:7006 --cluster-yes --cluster-replicas 1
```

## Check cluster

```bash
redis-cli -c -p 7001
cluster info
cluster nodes
```

## Data read/write

### Case 1

```bash
redis-cli -c -p 7002
set asd 123
exit

redis-cli -c -p 7002
get asd
```

### Case 2

```bash
redis-cli -c -p 7001 set foo bar
redis-cli -c -p 7003 get foo
```
