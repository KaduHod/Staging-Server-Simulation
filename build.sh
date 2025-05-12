#!/bin/bash
export $(grep -v '^#' .env | xargs)
docker build -t kaduhod/ubuntu --build-arg ROOT_PASSWORD=123456 --build-arg DOCKERHUB_KEY=$DOCKERHUB_KEY .
