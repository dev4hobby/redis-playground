MAKEFLAGS += --silent
path := .

.PHONY: help
help: ## 지금 보고있는거
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@awk '/^[a-zA-Z\-\_0-9]+:/ { \
		nb = sub( /^## /, "", helpMsg ); \
		if(nb == 0) { \
			helpMsg = $$0; \
			nb = sub( /^[^:]*:.* ## /, "", helpMsg ); \
		} \
		if (nb) \
			print $$1 " " helpMsg; \
	} \
	{ helpMsg = $$0 }' $(MAKEFILE_LIST) | \
		sort | \
		column -tx -s ':'

.PHONY: clean-cache
clean-cache: ## 캐시 및 필요없는 리소스 제거
	rm -rf `find . -name '__pycache__'`

.PHONY: build
build: ## 클러스터 레디스 환경 빌드
	if [ -z "$(MODE)" ]; then \
		echo "MODE is empty"; \
		echo "Usage: make build MODE=<mode>"; \
		exit 1; \
	fi
	docker-compose -f docker-compose-$(MODE).yaml build

.PHONY: up
up: ## 클러스터 레디스 환경 실행
	if [ -z "$(MODE)" ]; then \
		echo "MODE is empty"; \
		echo "Usage: make up MODE=<mode>"; \
		exit 1; \
	fi
	docker-compose -f docker-compose-$(MODE).yaml --env-file .env up

.PHONY: down
down: ## 레디스 환경 종료
	docker-compose -f docker-compose-cluster.yaml -f docker-compose-replica.yaml -f docker-compose-sentinel.yaml down --remove-orphans

.PHONY: stop-replica-master
stop-replica-master: ## 레플리카 마스터 레디스 종료
	docker-compose -f docker-compose-replica.yaml stop redis-primary

.PHONY: start-replica-master
start-replica-master: ## 레플리카 마스터 레디스 실행
	docker-compose -f docker-compose-replica.yaml restart redis-primary

.PHONY: stop-replica-slave
stop-replica-slave: ## 레플리카 슬레이브 레디스 종료
	docker-compose -f docker-compose-replica.yaml stop redis-replica

.PHONY: start-replica-slave
start-replica-slave: ## 레플리카 슬레이브 레디스 실행
	docker-compose -f docker-compose-replica.yaml restart redis-replica

.PHONY: stop-cluster-master
stop-cluster-master: ## 클러스터 마스터 레디스 종료
	if [ -z "$(ID)" ]; then \
		echo "ID is empty"; \
		echo "Usage: make stop-cluster-master ID=<id>"; \
		exit 1; \
	fi
	docker-compose -f docker-compose-cluster.yaml stop redis-primary-$(ID)

.PHONY: start-cluster-master
start-cluster-master: ## 클러스터 마스터 레디스 실행
	if [ -z "$(ID)" ]; then \
		echo "ID is empty"; \
		echo "Usage: make stop-cluster-master ID=<id>"; \
		exit 1; \
	fi
	docker-compose -f docker-compose-cluster.yaml restart redis-primary-$(ID)

.PHONY: stop-cluster-slave
stop-cluster-slave: ## 클러스터 슬레이브 레디스 종료
	if [ -z "$(ID)" ]; then \
		echo "ID is empty"; \
		echo "Usage: make stop-cluster-master ID=<id>"; \
		exit 1; \
	fi
	docker-compose -f docker-compose-cluster.yaml stop redis-replica-$(ID)

.PHONY: start-cluster-slave
start-cluster-slave: ## 클러스터 슬레이브 레디스 실행
	if [ -z "$(ID)" ]; then \
		echo "ID is empty"; \
		echo "Usage: make stop-cluster-master ID=<id>"; \
		exit 1; \
	fi
	docker-compose -f docker-compose-cluster.yaml restart redis-replica-$(ID)

.PHONY: client
client: ## 클라이언트 실행
	if [ -z "$(MODE)" ]; then \
		echo "MODE is empty"; \
		echo "Usage: make client MODE=<mode> TYPE=<type>"; \
		exit 1; \
	fi
	if [ -z "$(TYPE)" ]; then \
		echo "TYPE is empty"; \
		echo "Usage: make client MODE=<mode> TYPE=<type>"; \
		exit 1; \
	fi
	docker-compose -f docker-compose-$(MODE).yaml exec -- $(TYPE)-client /bin/sh -c "./redis-client"

.PHONY: shell
shell: ## 클라이언트 쉘 접속
	if [ -z "$(MODE)" ]; then \
		echo "MODE is empty"; \
		echo "Usage: make shell MODE=<mode> TYPE=<type>"; \
		exit 1; \
	fi
	if [ -z "$(TYPE)" ]; then \
		echo "TYPE is empty"; \
		echo "Usage: make shell MODE=<mode> TYPE=<type>"; \
		exit 1; \
	fi
	docker-compose -f docker-compose-$(MODE).yaml exec -- $(TYPE)-client /bin/sh

.PHONY: account
account: ## 계정 생성
	if [ -z "$(NAME)" ]; then \
		echo "NAME is empty"; \
		echo "Usage: make account NAME=<name>"; \
		exit 1; \
	fi
	python tool/acl_generator.py $(NAME)
