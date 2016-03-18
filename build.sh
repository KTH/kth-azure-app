#!/bin/bash

APP_NAME="kth-azure-app"
APP_VERSION="V.0.6"


echo "================================================================================"

echo "docker build -t $APP_NAME:$APP_VERSION . | grep Successfully | awk '{ print $3 }'"
DOCKER_IMAGE_ID=$(docker build -t $APP_NAME:$APP_VERSION . | grep Successfully | awk '{ print $3 }')

echo "================================================================================"

echo "docker images"
docker images

echo "================================================================================"

echo "docker tag $DOCKER_IMAGE_ID kth-docker-registry.sys.kth.se/$APP_NAME:$APP_VERSION"
docker tag $DOCKER_IMAGE_ID kth-docker-registry.sys.kth.se/$APP_NAME:$APP_VERSION

echo "================================================================================"

echo "docker push kth-docker-registry.sys.kth.se/$APP_NAME:$APP_VERSION"
docker push kth-docker-registry.sys.kth.se/$APP_NAME:$APP_VERSION

echo "================================================================================"

docker rmi $DOCKER_IMAGE_ID
docker rmi -f 0fce2c5bea4f

echo "================================================================================"

echo "docker images"
docker images
echo "================================================================================"
