path := .

define Comment
	- Run `make help` to see all the available options.
endef

.PHONY: help
help: ## Show this help message.
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: run-redis
run-redis: ## Run all redis container via docker-compose.
	docker-compose up -d

.PHONY: inspect-redis
inspect-redis: ## Inspect the redis container.
	docker exec -it redis-master-1 bash

.PHONY: clustering
clustering: ## Run the clustering script.
	docker exec -it redis-master-1 bash -c "redis-cli --cluster create 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003"

.PHONY: io-example
io-example: ## Run the io-example script.
	docker exec -it redis-master-1 bash -c "redis-cli -c -p 7001 set foo bar"
	docker exec -it redis-master-1 bash -c "redis-cli -c -p 7003 get foo"

.PHONY: install-kompose
install-kompose: ## Install kompose
	/bin/bash ./scripts/install-kompose.sh $(OS)

.PHONY: install-kubectl
install-kubectl: ## Install kubectl
	/bin/bash ./scripts/install-kubectl.sh $(OS)

.PHONY: install-kubectl-convert
install-kubectl-convert: ## Install kubectl convert
	/bin/bash ./scripts/install-kubectl-convert.sh $(OS)

.PHONY: kompose
kompose: ## Convert the kompose file to docker-compose.
	kompose convert --volumes hostPath
	kubectl apply -f redis-master-1-service.yaml,redis-master-2-service.yaml,redis-master-3-service.yaml,redis-master-1-deployment.yaml,redis-master-2-deployment.yaml,redis-master-3-deployment.yaml
	kubectl describe svc redis-master-1

.PHONY: clean
clean:
	docker compose down