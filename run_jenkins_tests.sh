#!/bin/bash
#######################################################
# ABOUT THIS SCRIPT
#
# Jenkins script for reliably running clean tests with current boxes
#
# Continuously builds assets using the included node container
# Doesn't seem to stop properly with ctrl-c
# use "docker stop <box_name>" to kill it
#######################################################
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

# install php deps
$DC run --rm phpfpm composer install

# run linter
$DC run --rm phpfpm env COMPOSER_ALLOW_SUPERUSER=1 composer sniff-summary

# install widgets and run tests
$DC run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env COMPOSER_ALLOW_SUPERUSER=1 composer coverageci

# stop and remove docker containers
$DC stop
$DC rm -f --all
