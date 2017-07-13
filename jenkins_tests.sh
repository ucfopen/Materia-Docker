#!/bin/bash
set -e

# clean migration files
rm -f $DIR/app/fuel/app/config/development/migrations.php
rm -f $DIR/app/fuel/app/config/test/migrations.php

# store the docker compose command to shorten the following commands
DC="docker-compose -f docker-compose.yml -f docker-compose.admin.yml"

# stop and remove docker containers
$DC stop
$DC rm -f --all

$DC pull
$DC build mysql
$DC build phpfpm

$DC run --rm phpfpm composer install

# install widgets and run tests
source ./run_tests.sh

# stop and remove docker containers
$DC stop
$DC rm -f --all
