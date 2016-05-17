#!/bin/bash

set -e


#####################################################################
# Passed argument
#
PID_FILE_NAME_OR_ID=$1

#####################################################################

PROJECT_GIT_REPO_PATH=$(pwd)
CURRENT_SCRIPT_ABSOLUTE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#####################################################################
# Generic helper functions.
#

# Print info to screen.
info() { printf "\n • \033[0;37m$@\033[0;0m\n"; }

debug() { printf "\n    – \033[0;37m$@\033[0;0m\n"; }

error() { printf "\n \033[0;31m$@\033[0;0m\n"; }

ok() { printf "\n \033[0;32m$@\033[0;0m\n\n"; }

#####################################################################
#
#
#

BLANK=""
PID_FILE_NAME_PREPATTERN=".PID-"

PID="${PID_FILE_NAME_OR_ID/$PID_FILE_NAME_PREPATTERN/$BLANK}"

#####################################################################

DOCKER_CONF_FILE=$PROJECT_GIT_REPO_PATH/docker.conf
if [ -a $DOCKER_CONF_FILE ]; then
  info "Reading docker.conf - project specific docker settings"
  source $DOCKER_CONF_FILE
else
  error "Missing /docker.conf - Please create from template docker.conf.in"
  exit -1;
fi

DOCKER_COMPOSE_ENV_FILE=$PROJECT_GIT_REPO_PATH/.env
if [ -a $DOCKER_COMPOSE_ENV_FILE ]; then
  info "Reading .env - docker/docker-compose settings"
  source $DOCKER_COMPOSE_ENV_FILE
else
  error "Missing /.env - Please create from template .env.in"
  exit -1;
fi

if [ -n $PID ]; then

  if [ ! -z $COMPOSE_PROJECT_NAME ]; then
    info "Ignoring COMPOSE_PROJECT_NAME specified in .env"
  fi

  export COMPOSE_PROJECT_NAME=$PID

  debug "DOCKER_HOST         : \033[0;33m$DOCKER_HOST\033[0;0m"
  debug "COMPOSE_PROJECT_NAME: \033[0;33m$COMPOSE_PROJECT_NAME\033[0;0m"


  if [ -z $PID_FILE_NAME_OR_ID ]; then
    error "No pid specified."
  fi
  ok "Running 'docker-compose ps' for $PID'"
  docker-compose ps

else
  error "No pid-file found $PROJECT_GIT_REPO_PATH/.env"
  exit -1;
fi
