#!/bin/bash

error() { printf "\n \033[0;31mERROR: $@\033[0;0m | $(date) \n"; }
passed() { printf "\n \033[0;32m   OK: $@\033[0;0m | $(date) \n\n"; }

# /redis will connect to redis and say OK, if it works.
MONITOR_URL="http://web:3000/redis";
PATTERN="ok"

sleep 5s

RESPONSE=`curl -s -S --max-time 30 $MONITOR_URL`

if [[ -z `echo $RESPONSE | grep $PATTERN` ]]; then
    error "URL '$MONITOR_URL' does not contain '$PATTERN'."
    exit -1
fi

passed "Basic test passed for '$MONITOR_URL'."

exit 0
