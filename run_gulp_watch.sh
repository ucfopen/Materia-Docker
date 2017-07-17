#!/bin/bash
#######################################################
# ABOUT THIS SCRIPT
#
# Continuously builds assets using the included node container
# Doesn't seem to stop properly with ctrl-c
# use "docker stop <box_name>" to kill it
#######################################################
set -e
docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm node gulp
