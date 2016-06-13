#!/bin/bash
set -e

# clean migration files
rm -f app/fuel/app/config/development/migrations.php
rm -f app/fuel/app/config/test/migrations.php

# stop and remove docker containers
docker-compose -f docker-compose.yml -f docker-compose.admin.yml stop
docker-compose -f docker-compose.yml -f docker-compose.admin.yml rm -f --all

docker-compose -f docker-compose.yml -f docker-compose.admin.yml pull
docker-compose -f docker-compose.yml -f docker-compose.admin.yml build mysql
docker-compose -f docker-compose.yml -f docker-compose.admin.yml build phpfpm

docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm phpfpm composer install

# clone the default widgets
source clone_widgets.sh

# install widgets and run tests
source run_tests.sh
