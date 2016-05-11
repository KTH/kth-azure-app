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

#####################################################################

PROJECT_GIT_REPO_PATH=$(pwd)
CURRENT_SCRIPT_ABSOLUTE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

#####################################################################
# Generic helper functions.
#

# Print info to screen.
info() { printf "\n • \033[0;37m$@\033[0;0m\n"; }

# Print info to screen.
debug() { printf "\n    – \033[0;37m$@\033[0;0m\n"; }


#####################################################################
#
#
#
PID_FILE_NAME_PREPATTERN=".PID-"

info "PID:s that you have started from $(pwd)"
debug "Note: Process may have terminated on Azure, this is not tested (yet).\n"

ls -a $PROJECT_GIT_REPO_PATH | grep .PID-
