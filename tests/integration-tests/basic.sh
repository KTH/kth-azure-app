#!/bin/bash

info() { printf "\033[1;35m\n    • %s\033[0;0m$@\n";  }
error() { printf "\033[0;31m    ERROR: $@\033[0;0m\n"; }
passed() { printf "\033[0;32m   OK: $@\033[0;0m\n"; }


#
# Path to the Cisco vpn client.
#
if [ -z "$URL_PREFIX" ]; then
    URL_PREFIX="http://web:3000/kth-azure-app"
    sleep 5s
fi

FAILED=""

#
# Curls a url and tests if the response contains a string.
# If it fails sets FAILED to true.
#
# Usage: expectPathToContain "/_monitor" "active"
#
expectPathToContain() {
    
    ENDPOINT="$1"
    PATTERN="$2"
    
    TEST_URL="$URL_PREFIX$ENDPOINT"

    curl -k -S --max-time 3 $TEST_URL > .curl.log 2>&1
    RESULT=$(cat .curl.log)
    
    if [[ "$RESULT" == *"$PATTERN"* ]]; then
        passed "$TEST_URL works, it contains $PATTERN." 
    else
        error "'$TEST_URL' does not contain pattern '$PATTERN'."
        FAILED="true"
    fi

}

# ---------------- Tests ----------------

expectPathToContain "/" "Continuous Delivery Reference Application"
expectPathToContain "/_monitor" "APPLICATION_STATUS: OK"
expectPathToContain "/_monitor" "SECRET_VALUE_ON__MONITOR"
expectPathToContain "/_monitor" "API Call: kth-azure-app"
expectPathToContain "/_about" "Docker image"


# Result
if [[ "$FAILED" != *"true"* ]]; then
    info "All end-to-end tests passed."
    exit 0
else
    echo ""
    exit 1
fi







