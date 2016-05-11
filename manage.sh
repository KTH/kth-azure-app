#!/bin/bash

set -e




#####################################################################
# Passed argument
#

# Docker-compose target environment [azure,f dev or other]
COMMAND=$1
PID=$2

#####################################################################
# Generic helper functions.
#

# Print info to screen.
info() { printf "\n • \033[0;37m$@\033[0;0m\n"; }

# Print info to screen.
debug() { printf "\n    – \033[0;37m$@\033[0;0m\n"; }

# Print info to screen.
error() { printf "\n\033[0;31m$@\033[0;0m\n"; }

# Print info to screen.
ok() { printf "\n\033[0;32m$@\033[0;0m\n"; }

# Print info to screen.
usage() { printf "
    Wrapper for docker-compose. Reads docker.conf and .env

    USAGE:  manage.sh [-up, -down pid, -down-all, -list]

          -config     View '.env' and 'docker.conf';
          -list       Lists all pid:s in $(pwd)
          -up         Start new instance
          -down pid   Stop an existing instance
                      Ex: mange.sh -down .PID-kth-app-11234
          -down-all   Stop all instances;
          -ps         View instances on DOCKER_HOST";
}

# No arguments passed to script.
if [ -a $1 ]; then
  usage
  exit 0;
fi

if [ $COMMAND == "-up"  ]; then
  ./.docker/up.sh
  ./.docker/list.sh
elif [ $COMMAND == "-down"  ]; then
  ./.docker/down.sh $PID
  ./.docker/list.sh
elif [ $COMMAND == "-down-all"  ]; then
  ./.docker/down-all.sh $PID
elif [ $COMMAND == "-list"  ]; then
  ./.docker/list.sh
elif [ $COMMAND == "-config"  ]; then
  ./.docker/config.sh
elif [ $COMMAND == "-ps"  ]; then
  ./.docker/ps.sh $PID
else
  usage
fi
