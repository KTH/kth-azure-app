#!/bin/bash

error() { printf "\n \033[0;31mERROR: $@\033[0;0m | $(date) \n"; }
passed() { printf "\n \033[0;32m   OK: $@\033[0;0m | $(date) \n\n"; }

MONITOR_URL="http://web:3000/kth-azure-app/_monitor";

PATTERN="SECRET_VALUE_ON__MONddddITOR" #env in docker-compose-integration-tests.yml

RESPONSE="$(curl -s -S --max-time 30 $MONITOR_URL)"
echo "$RESPONSE"

if [[ $RESPONSE != *$PATTERN* ]]; then
    error "URL '$MONITOR_URL' does not contain '$PATTERN'."
    exit 1
fi

passed "Basic test passed for '$MONITOR_URL'."
    
exit 0
