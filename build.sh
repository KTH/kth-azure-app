#!/bin/bash

APP_NAME="kth-azure-app"
APP_VERSION="V.0.10"


echo "================================================================================"

echo "docker build -t $APP_NAME:$APP_VERSION . | grep Successfully | awk '{ print $3 }'"
DOCKER_IMAGE_ID=$(docker build -t $APP_NAME:$APP_VERSION . | grep Successfully | awk '{ print $3 }')

echo "================================================================================"

echo "docker images"
docker images

echo "================================================================================"

echo "docker tag $DOCKER_IMAGE_ID kth-docker-registry.sys.kth.se/$APP_NAME:$APP_VERSION"
docker tag $DOCKER_IMAGE_ID kth-docker-registry.sys.kth.se/$APP_NAME:$APP_VERSION

echo "docker push kth-docker-registry.sys.kth.se/$APP_NAME:$APP_VERSION"
docker push kth-docker-registry.sys.kth.se/$APP_NAME:$APP_VERSION

echo "================================================================================"

echo "docker tag $DOCKER_IMAGE_ID kth-docker-registry.sys.kth.se/$APP_NAME:latest"
docker tag $DOCKER_IMAGE_ID kth-docker-registry.sys.kth.se/$APP_NAME:latest

echo "docker push kth-docker-registry.sys.kth.se/$APP_NAME:latest"
docker push kth-docker-registry.sys.kth.se/$APP_NAME:latest

echo "================================================================================"

echo "Clean up build"
docker rmi -f $DOCKER_IMAGE_ID

echo "================================================================================"

echo "docker images"
docker images

echo "================================================================================"
