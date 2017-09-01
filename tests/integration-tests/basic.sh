#!/bin/bash

set -e

error() { printf "\n \033[0;31mERROR: $@\033[0;0m | $(date) \n"; }
passed() { printf "\n \033[0;32m   OK: $@\033[0;0m | $(date) \n\n"; }

MONITOR_URL="http://web:3000/_monitor";
PATTERN="APPLICATION_STATUS"

RESPONSE=`curl -s -vvv --max-time 10 $MONITOR_URL`

if [[ -z `echo $RESPONSE | grep $PATTERN` ]]; then
    error "Monitor page '$MONITOR_URL' did not contain '$PATTERN'."
    exit -1
fi

passed "Basic monitor test passed for '$MONITOR_URL'."
