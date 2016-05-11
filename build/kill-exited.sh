#!/bin/bash

# Kill any containers that have exited and remove images
docker ps -a | awk '/Exited/ {print $1}' | xargs docker rm -v
docker rmi $(docker images -f "dangling=true" -q)