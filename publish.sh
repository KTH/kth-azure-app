#!/bin/bash

set -e

#####################################################################
#
# usage: publish.sh [azure] [dev]
#
# Setup: Create a locale env file for your target by copying
# docker-[azure,dev,other].env.in to docker-[azure,dev,other].env
# Your local docker-[azure,dev,other].env will not be added to Git.
#
#####################################################################

# /var/lib/jenkins/workspace/zermatt/jenkins
CURRENT_SCRIPT_ABSOLUTE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

TARGET=$1

source docker.conf

# The name to give the build, normally the project or gitrepo name.
if [ -z $IMAGE_NAME ]; then
  error "No label IMAGE_NAME specified in docker.conf"
  exit 1
fi

if [ -n "$TARGET" ]; then

  if [ -a $ENV_FILE ]; then
    # Export Docker envs for target enviroment.
    echo "=================== $TARGET ====================================================="
    source docker-$TARGET.env

    echo $DOCKER_HOST

    export COMPOSE_PROJECT_NAME=$IMAGE_NAME

    echo "Using COMPOSE_PROJECT_NAME: $COMPOSE_PROJECT_NAME"
    docker-compose up -d

  else
    echo -e "No matching target enviroment file found\n\nFile should be:   docker-[dev,azure].env\n"
  fi

else
  echo "Missing target enviroment [dev, azure]"
  echo "publish.sh [dev,azure]"
fi
