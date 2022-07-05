#!/bin/bash

kompose_version=$(kompose version | awk '{print $2}')

# if kompose version exists then skip
if [ -z "$kompose_version" ]; then
  echo "Kompose is not installed. Installing Kompose..."
  echo "[kompose] Downloading ..."

  if [ "$OS" = "linux" ]; then
    curl -L https://github.com/kubernetes/kompose/releases/download/v1.26.0/kompose-linux-amd64 -o kompose
  elif [ "$OS" = "mac" ]; then
    curl -L https://github.com/kubernetes/kompose/releases/download/v1.26.0/kompose-darwin-amd64 -o kompose
  elif [ "$OS" = "windows" ]; then
    curl -L https://github.com/kubernetes/kompose/releases/download/v1.26.0/kompose-windows-amd64.exe -o kompose.exe
  else
    echo "Usage: $0 <os>"
    echo "  os: linux|mac|windows"
    exit 1
  fi

  echo "[kompose] Downloaded"
  chmod +x kompose

  echo "[kompose] Please enter password!"
  sudo mv ./kompose /usr/local/bin/kompose

  echo "[kompose] Done"

else
  echo "Kompose is already installed. Skipping..."
fi



