#!/bin/bash

set -e

# =======================================
# Define helper functions
# =======================================

on_error() { printf "$@" 1>&2; docker rmi -f $DOCKER_IMAGE_ID; exit -1; }
output() { printf "\n\n======== $@\n"; }

CONFIG_FILE="docker.info"

output "Running build script on $DOCKER_HOST ..."

output "Loading app configuration from $CONFIG_FILE ..."

# =======================================
# Load application configuration settings
# =======================================

source $CONFIG_FILE

# =======================================
# Setup variables
# =======================================

REGISTRY="kth-docker-registry.sys.kth.se"
VERSION_TAG="$APP_VERSION"
LATEST_TAG="latest"

APP_NAME_FULL="$REGISTRY/$APP_NAME"

# =======================================
# Build image
# =======================================

output "Building $APP_NAME_FULL ..."
DOCKER_IMAGE_ID=$(docker build . | grep Successfully | awk '{ print $3 }')

# =======================================
# Tag image
# =======================================

output "Tagging image with '$APP_VERSION' and '$LATEST_TAG'"
docker tag $DOCKER_IMAGE_ID $APP_NAME_FULL:$APP_VERSION
docker tag $DOCKER_IMAGE_ID $APP_NAME_FULL:$LATEST_TAG
if ! [ -z "$CUSTOM_TAG" ]; then
  output "Adding custom tag '$CUSTOM_TAG' to image ..."
  docker tag $DOCKER_IMAGE_ID $APP_NAME_FULL:$CUSTOM_TAG
fi

# =======================================
# Check that we got back an image id
# =======================================

if [ -z "$DOCKER_IMAGE_ID" ]; then
  on_error "Docker build failed (no image was created)! Exiting"
fi

# =======================================
# Push the image to our repository
# =======================================

output "Pushing image to registry $REGISTRY ..."
docker push $APP_NAME_FULL

# =======================================
# Query API to make sure that the version tag was properly pushed
# =======================================

output "Querying the registry API to make sure tag version $APP_VERSION exists ..."
FOUND_VERSION=$(curl https://$REGISTRY:443/v2/$APP_NAME/tags/list | grep $APP_VERSION)

if [ -z "$FOUND_VERSION" ]; then
  on_error "Could not get version from repository. Maybe nothing changed in this build?"
fi

# =======================================
# Remove local images and finish
# =======================================

output "Removing local images ..."
docker rmi -f $DOCKER_IMAGE_ID

output "All done!"