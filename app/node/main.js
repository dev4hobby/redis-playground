import {
  getRedisClient,
  bulkInsert,
  bulkRead,
  bulk,
} from "./db.js"
import * as readline from 'node:readline'

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
})

const userInput = async (prompt) => {
  return new Promise(resolve => rl.question(prompt, resolve))
}

const printHelp = () => {
  console.log("Node Redis Playground")
  console.log("Commands:")
  console.log("  help")
  console.log("  exit")
  console.log("  bulk-insert <count>")
  console.log("  bulk-read <count>")
  console.log("  bulk <count>")
  console.log("  <command> <args>")
  console.log("Examples:")
  console.log("  set foo bar")
  console.log("  get foo")
  console.log("  del foo")
}

const playground = async (redis) => {
  while (true) {
    const line = await userInput("> ")
    if (line === "exit") {
      process.exit()
    } else if (line === "help") {
      printHelp()
    } else if (line === "") {
      continue
    } else {
      const args = line.split(" ").filter((arg) => arg !== "")
      const command = args[0]
      const commandArgs = args.slice(1)
      if (command === "bulk-insert") {
        await bulkInsert(parseInt(commandArgs[0]))
      } else if (command === "bulk-read") {
        await bulkRead(parseInt(commandArgs[0]))
      } else if (command === "bulk") {
        await bulk(parseInt(commandArgs[0]))
      } else {
        try {
          console.log(await redis[command](...commandArgs))
        } catch (error) {
          console.log("Error: " + error.message)
        }
      }
    }
  }
}

async function main(){
  const redis = await getRedisClient()
  console.log("Connected")
  console.log("Type 'help' for commands")
  await playground(redis)
}

await main()
process.exit()