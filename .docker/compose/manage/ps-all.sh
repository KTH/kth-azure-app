#!/bin/bash

set -e

#####################################################################

PROJECT_GIT_REPO_PATH=$(pwd)
CURRENT_SCRIPT_ABSOLUTE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


#####################################################################
# Passed argument
#
PID_FILE_NAME_OR_ID=$1

BLANK=""
PID_FILE_NAME_PREPATTERN=".PID-"

PID="${PID_FILE_NAME_OR_ID/$PID_FILE_NAME_PREPATTERN/$BLANK}"


#####################################################################
# Generic helper functions.
#

# Print info to screen.
info() { printf "\n • \033[0;37m$@\033[0;0m\n"; }

debug() { printf "\n    – \033[0;37m$@\033[0;0m\n"; }

error() { printf "\n \033[0;31m$@\033[0;0m\n"; }

ok() { printf "\n \033[0;32m$@\033[0;0m\n\n"; }


#####################################################################

if [ ! -z $PID ]; then
  $CURRENT_SCRIPT_ABSOLUTE_PATH/ps.sh $PID;
else
  for pidfromfile in $(ls -a $PROJECT_GIT_REPO_PATH | grep '.PID-'); do
    $CURRENT_SCRIPT_ABSOLUTE_PATH/ps.sh $pidfromfile;
  done;
fi


ok "Running 'docker ps -a'"
docker ps -a
