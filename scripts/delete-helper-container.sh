#!/bin/bash
CONTAINER_ID=$(docker ps -aq -f name=redis-clustering-helper)

# check docker container status by id
echo "Waiting for redis-clustering-helper done"
# write dot after each second
while [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_ID)" == "true" ]; do
  sleep 0.5
  echo -n "."
done

docker rm -f $CONTAINER_ID
echo "Helper container removed"