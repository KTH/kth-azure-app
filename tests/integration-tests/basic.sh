#!/bin/bash

error() { printf "\n \033[0;31mERROR: $@\033[0;0m | $(date) \n"; }
passed() { printf "\n \033[0;32m   OK: $@\033[0;0m | $(date) \n\n"; }

MONITOR_URL="http://web:3000/_monitor";
PATTERN="APPLICATION_STATUS"

sleep 5s

RESPONSE=`curl -s -S --max-time 30 $MONITOR_URL`

if [[ -z `echo $RESPONSE | grep $PATTERN` ]]; then
    error "Monitor page '$MONITOR_URL' did not contain '$PATTERN'."
    exit -1
fi

passed "Basic monitor test passed for '$MONITOR_URL'."

exit 0
