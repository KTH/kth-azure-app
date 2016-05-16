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

PID_FILE_NAME=".PID-$PID"

if [ -z $PID ]; then
  error "No pid passed to take down.\n"
  echo  "    USAGE: mange.sh -down .PID-kth-app-11234 / kth-app-11234"
  exit -1;
fi

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


  if [ ! -z $COMPOSE_PROJECT_NAME ]; then
    info "Ignoring COMPOSE_PROJECT_NAME specified in .env"
  fi

  export COMPOSE_PROJECT_NAME=$PID

  debug "COMPOSE_PROJECT_NAME: \033[0;33m$COMPOSE_PROJECT_NAME\033[0;0m"

  info "Running 'docker-compose down' on $PID ..."
  docker-compose down

  PID_FILE_NAME_PREPATTERN=".PID-"
  PID_FILE_NAME=$PID_FILE_NAME_PREPATTERN-$PID

  ok "$PID is down."

  if [ -a $PID_FILE_NAME ]; then
    debug "Removing pid-file for $PID"
    rm $PID_FILE_NAME
  else
    info "$PID had no pid file"
  fi
