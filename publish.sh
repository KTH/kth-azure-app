#!/bin/bash

set -e

# /var/lib/jenkins/workspace/zermatt/jenkins
CURRENT_SCRIPT_ABSOLUTE_PATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

TARGET=$1

echo "Target $TARGET"


if [ -n "$TARGET" ]; then

  ENV_FILE=$CURRENT_SCRIPT_ABSOLUTE_PATH/docker-$TARGET.env
  if [ -a $ENV_FILE ]; then
    # Export Docker envs for target enviroment.
    echo "=================== $TARGET ====================================================="
    source $CURRENT_SCRIPT_ABSOLUTE_PATH/docker-$TARGET.env

    export COMPOSE_PROJECT_NAME=$(basename $CURRENT_SCRIPT_ABSOLUTE_PATH)

    echo "Using COMPOSE_PROJECT_NAME: $COMPOSE_PROJECT_NAME"
    docker-compose up -d --build

  else
    echo -e "No matching target enviroment file found\n\nFile should be:   docker-[dev,azure].env\n"
  fi

else
  echo "Missing target enviroment [dev, azure]"
  echo "publish.sh [dev,azure]"
fi
