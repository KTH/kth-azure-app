#!/bin/bash

set -e


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


info "Taking down all instances that have a pid file in $(pwd)"

for pid in $(ls -a $PROJECT_GIT_REPO_PATH | grep '.PID-'); do
  $CURRENT_SCRIPT_ABSOLUTE_PATH/down.sh $pid;
done;

ok "All instances downed."
