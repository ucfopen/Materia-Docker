#!/bin/bash
#######################################################
# ABOUT THIS SCRIPT
#
# Builds assets using the included node container
#######################################################
set -e

NODE_DC_COMMAND="docker-compose -f docker-compose.yml -f docker-compose.admin.yml"

if [[ $GITHUB_GIT_USER = "" ]]; then
    echo "Warning: Missing env variable GITHUB_GIT_USER that may be needed for yarn install"
fi

if [[ $GITHUB_GIT_PASS = "" ]]; then
    echo "Warning: Missing env variable GITHUB_GIT_PASS that may be needed for yarn install"
fi


$NODE_DC_COMMAND run --rm node yarn install --silent --pure-lockfile --force
