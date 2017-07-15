#!/bin/bash
#######################################################
# ABOUT THIS SCRIPT
#
# Builds assets using the included node container
#######################################################
set -e
docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm node yarn run assets
