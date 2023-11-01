import logging
import asyncio
from time import time
from db import Redis

redis = Redis()


def print_help():
    print("Python Redis Playground")
    print("Commands:")
    print("  help")
    print("  exit")
    print("  bulk-insert <count>")
    print("  bulk-read <count>")
    print("  bulk <count>")
    print("  <command> <args>")
    print("Examples:")
    print("  set foo bar")
    print("  get foo")
    print("  del foo")


def parse_int_or_input(s) -> int:
    try:
        return int(s)
    except (ValueError, IndexError):
        while True:
            try:
                return int(input(s))
            except ValueError:
                print("Invalid input")


async def playground(redis_: Redis):
    print("Type 'help' for commands")
    while True:
        user_input = input(">> ")
        if not user_input:
            continue
        elif user_input == "exit":
            break
        elif user_input == "help":
            print_help()
            continue
        args = [arg for arg in user_input.split() if arg]
        if args[0] == "bulk-insert":
            count = parse_int_or_input(args[1])
            previous = time()
            for i in range(count):
                key = f"foo-{i}"
                value = f"bar-{i}"
                resp = await redis_.set(key, value)
            now = time()
            # print milliseconds
            rounded_diff = int(round((now - previous) * 1000))
            print(f"inserted {count} keys in {rounded_diff}ms")
            continue
        elif args[0] == "bulk-read":
            count = parse_int_or_input(args[1])
            previous = time()
            for i in range(count):
                key = f"foo-{i}"
                resp = await redis_.get(key)
            now = time()
            rounded_diff = int(round((now - previous) * 1000))
            print(f"read {count} keys in {rounded_diff}ms")
            continue
        elif args[0] == "bulk":
            count = parse_int_or_input(args[1])
            previous = time()
            for i in range(count):
                key = f"foo-{i}"
                value = f"bar-{i}"
                resp = await redis_.set(key, value)
                resp = await redis_.get(key)
            now = time()
            rounded_diff = int(round((now - previous) * 1000))
            print(f"read and write {count} keys in {rounded_diff}ms")
            continue
        try:
            resp = await redis_.execute_command(*args)
        # pylint: disable=broad-except
        except Exception as e:
            resp = e
        print(resp)


async def main():
    await redis.initialize()
    await playground(redis)
    await redis.destroy()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    asyncio.run(main())
