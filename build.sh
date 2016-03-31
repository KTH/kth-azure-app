#!/bin/bash

set -e

# =======================================
# Define helper functions
# =======================================

echo_err() { printf "$@" 1>&2; exit -1; }
output() { printf "\n\n========"; printf "$@\n"; }

CONFIG_FILE="docker.info"

output "Loading app configuration from $CONFIG_FILE ..."

# =======================================
# Load application configuration settings
# =======================================

source $CONFIG_FILE

# =======================================
# Setup variables
# =======================================

REGISTRY="kth-docker-registry.sys.kth.se"
CUSTOM_TAG="$1"
VERSION_TAG="$APP_VERSION"
LATEST_TAG="latest"
TAGS="-t $REGISTRY/$APP_NAME:$VERSION_TAG -t $REGISTRY/$APP_NAME:$LATEST_TAG"

# =======================================
# Add custom tag if provided
# =======================================

if [ -z "$CUSTOM_TAG" ]; then
  output "Building version $APP_VERSION of $APP_NAME with no custom tag ..."
else
  output "Building version $APP_VERSION of $APP_NAME with custom tag: $CUSTOM_TAG ..."
  TAGS="$TAGS -t $REGISTRY/$APP_NAME:$CUSTOM_TAG"
fi

# =======================================
# Build image with all the tags
# =======================================

DOCKER_IMAGE_ID=$(docker build $TAGS . | grep Successfully | awk '{ print $3 }')

# =======================================
# Check that we got back an image id
# =======================================

if [ -z "$DOCKER_IMAGE_ID" ]; then
  echo_err "Docker build failed (no image was created)! Exiting"
fi

# =======================================
# Push the image to our repository
# =======================================

output "Pushing image to registry $REGISTRY ..."
docker push $REGISTRY/$APP_NAME

# =======================================
# Query API to make sure that the version tag was properly pushed
# =======================================

output "Querying the registry API to make sure tag version $APP_VERSION exists ..."
FOUND_VERSION=$(curl https://$REGISTRY:443/v2/$APP_NAME/tags/list | grep $APP_VERSION)

if [ -z "$FOUND_VERSION" ]; then
  echo_err "Could not get version from repository. Maybe nothing changed in this build?"
else
  # =======================================
  # Remove local images and finish
  # =======================================

  output "Removing local images ..."
  docker rmi -f $DOCKER_IMAGE_ID

  output "All done!"
fi