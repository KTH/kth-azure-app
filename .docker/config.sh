#!/bin/bash

set -e


PROJECT_GIT_REPO_PATH=$(pwd)
CURRENT_SCRIPT_ABSOLUTE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


#####################################################################
# Passed argument
#

#####################################################################
# Generic helper functions.
#

# Print info to screen.
error() { printf "\n \033[0;31m$@\033[0;0m\n"; }

ok() { printf "\n \033[0;32m$@\033[0;0m\n\n"; }

#####################################################################


DOCKER_CONF_FILE=$PROJECT_GIT_REPO_PATH/docker.conf

if [ -a $DOCKER_CONF_FILE ]; then
  ok "Configuration file docker.conf"
  cat $DOCKER_CONF_FILE
else
  error "Missing /docker.conf - Please create from template docker.conf.in"
fi

DOCKER_COMPOSE_ENV_FILE=$PROJECT_GIT_REPO_PATH/.env
if [ -a $DOCKER_COMPOSE_ENV_FILE ]; then
  ok "Configuration file .env"
  cat $DOCKER_COMPOSE_ENV_FILE
else
  error "Missing /.env - Please create from template .env.in"
fi
