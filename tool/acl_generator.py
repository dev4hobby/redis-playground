import hashlib
from os import sys
from datetime import datetime


def generate_hashstring(string: str, length: int = 16) -> str:
    return hashlib.sha256(string.encode()).hexdigest()[:length]


def str_to_sha256(string: str) -> str:
    return hashlib.sha256(string.encode()).hexdigest()


def generate_password(name: str, target: str) -> tuple[str, str]:
    password = generate_hashstring(
        f"d3fau1t-{name}-{target}-{datetime.now().strftime('%Y-%m-%d-%H-%M-%S')}"
    )
    sha256_password = str_to_sha256(password)
    print(f"Password: {password}")
    print(f"SHA256: {sha256_password}")
    return password, sha256_password


def create_acl_resource(name: str) -> str:
    deploy_target = {
        "local": {
            "host": "localhost",
            "port": "7001",
        },
    }

    for target, info in deploy_target.items():
        file_name = f"{name}-{target}.csv"
        acl_name = f"{name}-{target}.acl"
        print(f"{name = }: {target = }")
        password, sha256_password = generate_password(name, target)
        with open(file_name, "w", encoding="utf-8") as f:
            f.write("id,password,host,port,name(namespace)\n")
            f.write(f"{name},{password},{info['host']},{info['port']},{name}:")
        with open(acl_name, "w",  encoding="utf-8") as f:
            f.write(
                f"user {name} on #{sha256_password} ~{name}"
                +":* &* +get +set +del +eval +info +cluster|slots +command"
            )

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <name>")
        sys.exit(1)
    create_acl_resource(sys.argv[1])
