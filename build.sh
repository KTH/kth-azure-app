#!/bin/bash

set -e


echo " * * * * * * * * * * * * * * * * * * * * * * * * * *"
echo " * To be deprecated                                *"
echo " * Clone https://gita.sys.kth.se/Infosys/zermatt   *"
echo " * and build with zermatt/jenkins/docker-build.sh  *"
echo " * * * * * * * * * * * * * * * * * * * * * * * * * *"
# =======================================
# Define helper functions
# =======================================

on_error() { printf "$@" 1>&2; docker rmi -f $DOCKER_IMAGE_ID; exit -1; }
output() { printf "\n\n======== $@\n"; }

CONFIG_FILE="docker.conf"

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
VERSION_TAG="$IMAGE_VERSION"
LATEST_TAG="latest"

IMAGE_NAME_FULL="$REGISTRY/$IMAGE_NAME"

# =======================================
# Build image
# =======================================

output "Building $IMAGE_NAME_FULL ..."
DOCKER_IMAGE_ID=$(docker build . | grep Successfully | awk '{ print $3 }')

# =======================================
# Tag image
# =======================================

output "Tagging image with '$IMAGE_VERSION' and '$LATEST_TAG'"
docker tag $DOCKER_IMAGE_ID $IMAGE_NAME_FULL:$IMAGE_VERSION
docker tag $DOCKER_IMAGE_ID $IMAGE_NAME_FULL:$LATEST_TAG
if ! [ -z "$CUSTOM_TAGS" ]; then
  output "Adding custom tag '$CUSTOM_TAGS' to image ..."
  docker tag $DOCKER_IMAGE_ID $IMAGE_NAME_FULL:$CUSTOM_TAGS
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
#docker push $IMAGE_NAME_FULL

# =======================================
# Query API to make sure that the version tag was properly pushed
# =======================================

output "Querying the registry API to make sure tag version $IMAGE_VERSION exists ..."
FOUND_VERSION=$(curl https://$REGISTRY:443/v2/$IMAGE_NAME/tags/list | grep $IMAGE_VERSION)

if [ -z "$FOUND_VERSION" ]; then
  on_error "Could not get version from repository. Maybe nothing changed in this build?"
fi

# =======================================
# Remove local images and finish
# =======================================

output "Removing local images ..."
docker rmi -f $DOCKER_IMAGE_ID

output "All done!"
