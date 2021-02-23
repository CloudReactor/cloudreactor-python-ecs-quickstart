#!/bin/bash

echo "Copying requirement files back to host ..."
IMAGE_NAME=cloudreactor-ecs-quickstart-dev
TEMP_CONTAINER_NAME="$IMAGE_NAME-temp"

docker create --name $TEMP_CONTAINER_NAME $IMAGE_NAME
docker cp $TEMP_CONTAINER_NAME:/tmp/requirements.txt requirements.txt
docker cp $TEMP_CONTAINER_NAME:/tmp/dev-requirements.txt dev-requirements.txt
docker rm $TEMP_CONTAINER_NAME

echo "Done copying requirement files back to host."
