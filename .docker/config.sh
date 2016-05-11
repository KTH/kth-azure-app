#!/bin/bash

set -e

#####################################################################
# Passed argument
#

#####################################################################
# Generic helper functions.
#

# Print info to screen.
ok() { printf "\n\033[0;32m$@\033[0;0m\n"; }

ok "Configuration file docker.conf"
cat ./docker.conf
ok "Configuration file .env"
cat .env
