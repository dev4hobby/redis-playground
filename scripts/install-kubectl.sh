#!/bin/bash

kubectl_version=$(kubectl version | awk '{print $2}')

# if kompose version exists then skip
if [ -z "$kubectl_version" ]; then
  echo "kubectl is not installed. Installing kubectl..."
  echo "[kubectl] Downloading ..."

  if [ "$OS" = "linux" ]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  elif [ "$OS" = "mac-intel" ]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
  elif [ "$OS" = "mac-m1" ]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl"
  elif [ "$OS" = "windows" ]; then
    curl -LO "https://dl.k8s.io/release/v1.24.0/bin/windows/amd64/kubectl.exe"
  else
    echo "Usage: $0 <os>"
    echo "  os: linux|windows|mac-intel|mac-m1"
    exit 1
  fi

  echo "[kubectl] Downloaded"
  chmod +x ./kubectl

  echo "[kubectl] Please enter password!"
  sudo mv ./kubectl /usr/local/bin/kubectl
  sudo chown root: /usr/local/bin/kubectl

  echo "[kubectl] Done"

  echo "[kubectl-convert] Downloading ..."
  if [ "$OS" = "linux" ]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"
  elif [ "$OS" = "mac-intel" ]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl-convert"
  elif [ "$OS" = "mac-m1" ]; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/arm64/kubectl-convert"
  else
    curl -LO "https://dl.k8s.io/release/v1.24.0/bin/windows/amd64/kubectl-convert.exe"
  fi

  echo "[kubectl-convert] Downloaded"
  chmod +x ./kubectl-convert
  sudo mv ./kubectl-convert /usr/local/bin/kubectl-convert
  sudo chown root: /usr/local/bin/kubectl-convert
  kubectl convert --help
  echo "[kubectl-convert] Done"
else
  echo "kubectl-convert is already installed. Skipping..."
fi



