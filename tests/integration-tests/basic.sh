#!/bin/bash

info() { printf "\033[1;31m\n   %s\033[0;0m$@\n\n";  }
error() { printf "\033[0;31m\n • $@\033[0;0m"; }
passed() { printf "\033[0;32m • $@\033[0;0m\n"; }

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
    FAILURE_INFO="$3"
    
    TEST_URL="$URL_PREFIX$ENDPOINT"

    curl -k -S --max-time 3 $TEST_URL > .curl.log 2>&1
    RESULT=$(cat .curl.log)
    
    if [[ "$RESULT" == *"$PATTERN"* ]]; then
        if [ ! -z "$FAILURE_INFO" ]; then
            passed "$FAILURE_INFO."
        else 
            passed "$TEST_URL contains $PATTERN"
        fi
 
    else
        if [ ! -z "$FAILURE_INFO" ]; then
            error "$FAILURE_INFO"
        fi
        info "'$TEST_URL' does not contain pattern '$PATTERN'."
        
        FAILED="true"
    fi

}

# ---------------- Tests ----------------

expectPathToContain "/" "Continuous Delivery Reference Application" "The index page should contain a title"
expectPathToContain "/_monitor" "APPLICATION_STATUS: OK" "Always show OK as status"
expectPathToContain "/_monitor" "SECRET_VALUE_ON__MONITOR" "Show env SECRET_VALUE_ON__MONITOR to test that the pipeline handles secrets.env"
expectPathToContain "/_monitor" "API Call: kth-azure-app" "Make external call to the api to check network issues. (Yes I know, it works ok...)"
expectPathToContain "/_about" "Docker image" "About pages should contain Docker image information"
expectPathToContain "/502" "502 Bad Gateway" "Return a 502 Bad Gateway for the cluster proxy to handle."
expectPathToContain "/missing" "Page not found" "404:s should be handled."
expectPathToContain "/favicon.ico" "" "Show nothing for favicon.ico"
expectPathToContain "/robots.txt" "User-agent: *" "Search bots should index nothing"
expectPathToContain "/robots.txt" "Disallow: /" "Search bots should index nothing"

# Result
if [[ "$FAILED" != *"true"* ]]; then
    info "All end-to-end tests passed."
    exit 0
else
    echo ""
    exit 1
fi







