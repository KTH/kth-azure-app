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



#####################################################################
# Passed argument
#

# Docker-compose target environment [azure,f dev or other]
TARGET=$1

#####################################################################
# Generic helper functions.
#

# Print info to screen.
info() { printf "\n • $@\n\n"; }

# Print info to screen.
debug() { printf "\n    – $@\n"; }

# Print info to screen.
error() { printf "\n######################################\n\n$@\n######################################\n"; }

# Clean up on error.
on_error() { printf "$@" 1>&2; docker rmi -f $DOCKER_IMAGE_ID; exit -1; }


info "Reading project specific docker settings"
source docker.conf

# The name to give the build, normally the project or gitrepo name.
if [ -z $IMAGE_NAME ]; then
  error "No label IMAGE_NAME specified in docker.conf"
fi

if [ -n "$TARGET" ]; then

  if [ -a $ENV_FILE ]; then
    # Export Docker envs for target enviroment.
    info "Setting target enviroment from docker-$TARGET.env"

    source docker-$TARGET.env

    debug "Using host $DOCKER_HOST"

    COMPOSE_PROJECT_NAME=$IMAGE_NAME

    debug "Using COMPOSE_PROJECT_NAME: $COMPOSE_PROJECT_NAME"

    info "Runngin docker-compose up -d to $TARGET"
    docker-compose up -d

  else
    error "No matching target enviroment file found\n\nFile should be:   docker-[dev,azure].env\n"
  fi

else
  error "Missing target enviroment [dev, azure]\npublish.sh [dev,azure]"
fi
