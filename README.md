# README

Redis 환경 구축 및 테스트를 위한 Dockerfile 및 기타 리소스가 작성되어있는 저장소입니다.

- [Replica](./docker-compose-replica.yaml), [Cluster](./docker-compose-cluster.yaml) 구성의 시스템을 테스트해볼 수 있습니다.
  - Replica 구성에 [Sentinel](./docker-compose-sentinel.yaml)을 포함하여 테스트해볼 수 있습니다.
- [ACL](redis/acl/local.acl)이 적용되어있습니다.
  - *default 계정으로 접속할 수 있습니다.*
    - username: default
    - password: b555108fbcf909c6
  - 다른 계정을 만드시려면 [redis/acl/local.acl](redis/acl/local.acl) 파일을 수정해주세요.
    - [tools/acl_generator.py](tool/acl_generator.py) 스크립트로 계정을 생성할 수 있습니다.
- 기본 설정을 위한 파일은 [redis/common](./redis/common)에 있습니다.
  - AOF 설정은 [appendonly.conf](./redis/common/appendonly.conf) 를 확인해주세요.
    - 계정 추가시 [tools/acl_generator.py](tool/acl_generator.py) 스크립트로 생성한 acl 정보를 이 파일에 추가해주세요.
  - cluster 설정은 [cluster.conf](./redis/common/cluster.conf) 를 확인해주세요.
  - network i/o 다중화 설정은 [io-multi-threads.conf](./redis/common/io-multi-thread.conf) 를 확인해주세요.
  - 커맨드 관련 설정은 [rename-commands.conf](./redis/common/rename-commands.conf) 를 확인해주세요.
- cluster 구성을 위한 설정파일은 [redis/nodes/cluster](./redis/nodes/cluster)에 있습니다.
- replica 구성을 위한 설정파일은 [redis/nodes/replica](./redis/nodes/replica)에 있습니다.
- sentinel 구성을 위한 설정파일은 [redis/nodes/sentinel](./redis/nodes/sentinel)에 있습니다.

## 사용법

```bash
❯ make help
Usage: make [target]

Targets:
help                   지금 보고있는거
account                계정 생성
build                  클러스터 레디스 환경 빌드
clean-cache            캐시 및 필요없는 리소스 제거
client                 클라이언트 실행
up                     클러스터 레디스 환경 실행
down                   레디스 환경 종료
shell                  클라이언트 쉘 접속
start-cluster-master   클러스터 마스터 레디스 실행
stop-cluster-master    클러스터 마스터 레디스 종료
start-cluster-slave    클러스터 슬레이브 레디스 실행
stop-cluster-slave     클러스터 슬레이브 레디스 종료
start-replica-master   레플리카 마스터 레디스 실행
stop-replica-master    레플리카 마스터 레디스 종료
start-replica-slave    레플리카 슬레이브 레디스 실행
stop-replica-slave     레플리카 슬레이브 레디스 종료
```

### 클러스터 구성

```bash
make build MODE=cluster
make up MODE=cluster
```

Primary 3개, Replica 3개로 구성된 레디스 클러스터를 구성합니다.
별도로 [redis-stat](https://github.com/junegunn/redis-stat), [load_generator](./app/python/load_generator.py), [retriever](./app/python/retriever.py) 컨테이너가 같이 실행됩니다.

- redis-stat: 클러스터의 상태를 확인할 수 있는 모니터링 툴입니다.
- load_generator: 실행시점부터 종료이전까지 임의의 데이터를 GET, SET 하는 툴입니다.
- retriever: 실행시점부터 종료이전까지 임의의 데이터를 GET 하는 툴입니다.

테스트를 위해 추가되었으며 필요시 각각의 docker-compose 파일에서 제거하시면 됩니다.

### 클러스터 구성 후 클라이언트 접속

```bash
make client MODE=cluster TYPE=python
make client MODE=cluster TYPE=node
make client MODE=cluster TYPE=go
```

Python, Node, Go 클라이언트로 작성된 redis 쉘에 접속할 수 있습니다.

- [Python](./app/python/main.py)
- [Node](./app/node/main.js)
- [Go](./app/go/src/main.go)

`execute_command` 를 사용하여 명령어를 레디스 서버에 전송하고 응답을 받도록 작성되었습니다.
Python 클라이언트로 한번 감싸져있을 뿐, 실제 클라이언트와 별다른 차이는 없습니다.

### 레플리카 구성

```bash
make build MODE=replica
make up MODE=replica
```

Master, Slave로 구성된 레플리카 레디스 환경을 구성합니다.

장애복구를 위한 Sentinel은 포함되지 않습니다.

### 센티넬 구성

```bash
make build MODE=sentinel
make up MODE=sentinel
```

Master, Slave, Sentinel로 구성된 레디스 환경을 구성합니다.

Master 노드에 장애가 발생하면 Sentinel이 Slave 노드 중 하나를 Master로 승격시키기 때문에, 장애 발생 시간을 줄여줍니다.

### 종료

```bash
make down
```

사용하던 모든 리소스를 정리합니다.
