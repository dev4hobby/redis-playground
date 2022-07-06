#!/bin/bash

minikube_version=$(minikube version | awk '{print $2}')

# if kompose version exists then skip
if [ -z "$minikube_version" ]; then
  echo "minikube is not installed. Installing minikube..."
  echo "[minikube] Downloading ..."
  echo "[NOTICE] if you wanna get other architecture binary, please check manually from 'https://minikube.sigs.k8s.io/docs/start/'"
  if [ "$OS" = "linux" ]; then
    curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
    mv ./minikube-linux-amd64 ./minikube
  elif [ "$OS" = "mac-intel" ]; then
    curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64"
    mv ./minikube-darwin-amd64 ./minikube
  elif [ "$OS" = "mac-m1" ]; then
    curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-arm64"
    mv ./minikube-darwin-amd64 ./minikube
  else
    echo "Usage: $0 <os>"
    echo "  os: linux|mac-intel|mac-m1"
    exit 1
  fi

  echo "[minikube] Downloaded"

  echo "[minikube] Please enter password!"
  sudo install minikube

  echo "[minikube] Installed"

  echo "[minikube] Setup"
  if [ "$OS" = "mac-m1" ]; then
    minikube start --driver=docker --container-runtime=containerd
  else
    minikube start --vm-driver=virtualbox
  fi

  echo "[kubectl] is provider by minikube"
  kubectl config view | grep provider
  echo "[minikube] addon lists"
  minikube addons list
  echo "[minikube] Done"
  echo "if you wanna know more about minikube, please visit 'https://minikube.sigs.k8s.io/docs/start/'"
else
  echo "minikube is already installed. Skipping..."
  echo "if you wanna know more about minikube, please visit 'https://minikube.sigs.k8s.io/docs/start/'"
fi



