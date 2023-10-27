#!/bin/bash
sleep 5
redis-cli --cluster create \
  127.0.0.1:7001 \
  127.0.0.1:7002 \
  127.0.0.1:7003 \
  127.0.0.1:7004 \
  127.0.0.1:7005 \
  127.0.0.1:7006 \
  --cluster-yes \
  --cluster-replicas 1 \
  --user default \
  --pass b555108fbcf909c6
echo "Done!"