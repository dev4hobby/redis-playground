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
