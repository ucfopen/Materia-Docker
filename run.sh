#!/bin/bash
#######################################################
# ABOUT THIS SCRIPT
#
# Run ad hoc commands on the phpfpm container
#
# Arguments are executed string
# EX: ./run.sh echo "hello"
# EX: ./run.sh composer update
# EX: ./run.sh composer test --group=Lti
#######################################################

set -e

DC="docker-compose -f docker-compose.yml -f docker-compose.admin.yml"

$DC run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env COMPOSER_ALLOW_SUPERUSER=1 "$@"
