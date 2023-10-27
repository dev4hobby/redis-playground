package main

import (
	"bufio"
	"context"
	"fmt"
	"os"
	"strings"

	"github.com/redis/go-redis/v9"
)

type RedisEnv struct {
	redisAddrs          string
	redisMode           string
	redisSentinelName   string
	redisUsername       string
	redisPassword       string
	redisMaxConnections string
	redisDBIndex        string
}

type RedisClientMetadata struct {
	clientType    string
	clusterClient *redis.ClusterClient
	commonClient  *redis.Client
}

func getEnv(key, defaultValue string) string {
	value := os.Getenv(key)
	if len(value) == 0 {
		return defaultValue
	}
	return value
}

func splitString(input string, delimiter string) []string {
	return strings.Split(input, delimiter)
}

func replaceString(input string, old string, new string) string {
	return strings.ReplaceAll(input, old, new)
}

func getRedisEnv() RedisEnv {
	redisAddrs := getEnv("REDIS_ADDRS", "redis://localhost:6379")
	redisMode := getEnv("REDIS_MODE", "cluster")
	redisSentinelName := getEnv("REDIS_SENTINEL_NAME", "mymaster")
	redisUsername := getEnv("REDIS_USER", "")
	redisPassword := getEnv("REDIS_PASSWORD", "")
	redisMaxConnections := getEnv("REDIS_MAX_CONNECTIONS", "1000")
	redisDBIndex := getEnv("REDIS_DB", "0")

	return RedisEnv{
		redisAddrs:          redisAddrs,
		redisMode:           redisMode,
		redisSentinelName:   redisSentinelName,
		redisUsername:       redisUsername,
		redisPassword:       redisPassword,
		redisMaxConnections: redisMaxConnections,
		redisDBIndex:        redisDBIndex,
	}
}

func connectToCluster() RedisClientMetadata {
	redisEnv := getRedisEnv()
	redisAddrs := replaceString(redisEnv.redisAddrs, "redis://", "")
	fmt.Println("redisAddrs", redisAddrs)
	clusterClient := redis.NewClusterClient(&redis.ClusterOptions{
		Addrs:    splitString(redisAddrs, ","),
		Username: redisEnv.redisUsername,
		Password: redisEnv.redisPassword,
	})
	ctx := context.Background()
	_, err := clusterClient.Ping(ctx).Result()
	if err != nil {
		panic(err)
	}
	return RedisClientMetadata{
		clientType:    "cluster",
		clusterClient: clusterClient,
	}
}

func connectToSentinel() RedisClientMetadata {
	redisEnv := getRedisEnv()
	redisAddrs := replaceString(redisEnv.redisAddrs, "redis://", "")
	sentinelClient := redis.NewFailoverClient(&redis.FailoverOptions{
		MasterName:    redisEnv.redisSentinelName,
		SentinelAddrs: splitString(redisAddrs, ","),
		Username:      redisEnv.redisUsername,
		Password:      redisEnv.redisPassword,
	})
	ctx := context.Background()
	_, err := sentinelClient.Ping(ctx).Result()
	if err != nil {
		panic(err)
	}
	return RedisClientMetadata{
		clientType:   "sentinel",
		commonClient: sentinelClient,
	}
}

func connectToReplica() RedisClientMetadata {
	redisEnv := getRedisEnv()
	redisAddrs := replaceString(redisEnv.redisAddrs, "redis://", "")
	replicaClient := redis.NewClient(&redis.Options{
		Addr:     redisAddrs,
		Username: redisEnv.redisUsername,
		Password: redisEnv.redisPassword,
	})
	ctx := context.Background()
	_, err := replicaClient.Ping(ctx).Result()
	if err != nil {
		panic(err)
	}
	return RedisClientMetadata{
		clientType:   "replica",
		commonClient: replicaClient,
	}
}

func getRedisClientOrCluster() RedisClientMetadata {
	redisMode := getRedisEnv().redisMode
	if redisMode == "cluster" {
		fmt.Println("Connecting to cluster")
		return connectToCluster()
	} else if redisMode == "sentinel" {
		fmt.Println("Connecting to sentinel")
		return connectToSentinel()
	} else {
		fmt.Println("Connecting to standalone")
		return connectToReplica()
	}
}

func executeCommandOnCluster(client *redis.ClusterClient, args ...interface{}) {
	ctx := context.Background()
	cmd := client.Do(ctx, args...)
	resp, err := cmd.Result()
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	fmt.Println(resp)
}

func executeCommandOnCommon(client *redis.Client, args ...interface{}) {
	ctx := context.Background()
	resp, err := client.Do(ctx, args...).Result()
	if err != nil {
		fmt.Println(err.Error())
		return
	}
	fmt.Println(resp)
}

func executeCommandByClientType(client RedisClientMetadata, args ...interface{}) {
	if client.clientType == "cluster" {
		executeCommandOnCluster(client.clusterClient, args...)
	} else {
		executeCommandOnCommon(client.commonClient, args...)
	}
}

func bulk(client RedisClientMetadata) {
	count := parseInt(userInput("Count: "))

	for i := 0; i < count; i++ {
		executeCommandByClientType(client, "SET", fmt.Sprintf("foo-%d", i), fmt.Sprintf("bar-%d", i))
		executeCommandByClientType(client, "GET", fmt.Sprintf("foo-%d", i))
	}
}

func bulkRead(client RedisClientMetadata) {
	count := parseInt(userInput("Count: "))

	for i := 0; i < count; i++ {
		executeCommandByClientType(client, "GET", fmt.Sprintf("foo-%d", i))
	}
}

func bulkInsert(client RedisClientMetadata) {
	count := parseInt(userInput("Count: "))

	for i := 0; i < count; i++ {
		executeCommandByClientType(client, "SET", fmt.Sprintf("foo-%d", i), fmt.Sprintf("bar-%d", i))
	}
}

func userInput(prefix string) string {
	var input string
	fmt.Print(prefix)
	reader := bufio.NewReader(os.Stdin)

	input, _ = reader.ReadString('\n')
	input = strings.TrimSpace(input)
	return input
}

func parseInt(input string) int {
	var result int
	_, err := fmt.Sscanf(input, "%d", &result)
	if err != nil {
		return 0
	}
	return result
}

func screenClear() {
	fmt.Print("\033[H\033[2J")
}

func printHelp() {
	fmt.Println("Go Redis Playground")
	fmt.Println("Commands:")
	fmt.Println("  clear - clear the screen")
	fmt.Println("  help - print this help message")
	fmt.Println("  exit - exit the program")
	fmt.Println("  bulk-insert <count>")
	fmt.Println("  bulk-read <count>")
	fmt.Println("  bulk <count>")
	fmt.Println("  <command> <args>")
	fmt.Println("Examples:")
	fmt.Println("  set foo bar")
	fmt.Println("  get foo")
	fmt.Println("  del foo")
}

func playground(client RedisClientMetadata) {
	if client.clientType == "cluster" {
		defer client.clusterClient.Close()
	} else {
		defer client.commonClient.Close()
	}
	for {
		input := userInput(">> ")
		if len(input) == 0 {
			continue
		}
		fields := splitString(input, " ")
		var args []interface{} = make([]interface{}, len(fields))
		for i, v := range fields {
			args[i] = v
		}

		command := args[0].(string)
		// argsExceptCommand := args[1:]

		if command == "exit" {
			break
		} else if command == "help" {
			printHelp()
		} else if command == "clear" {
			screenClear()
		} else if command == "bulk" {
			bulk(client)
		} else if command == "bulk-read" {
			bulkRead(client)
		} else if command == "bulk-insert" {
			bulkInsert(client)
		} else {
			executeCommandByClientType(client, args...)
		}
	}
}

func main() {
	var clientMeta RedisClientMetadata = getRedisClientOrCluster()
	fmt.Println("Connected")
	fmt.Println("Try 'help' for commands")
	playground(clientMeta)
}
