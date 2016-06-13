#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# clean migration files
rm -f $DIR/app/fuel/app/config/development/migrations.php
rm -f $DIR/app/fuel/app/config/test/migrations.php

# stop and remove docker containers
docker-compose stop
docker-compose rm -f --all

docker-compose pull
docker-compose build mysql
docker-compose build phpfpm

docker-compose run --rm phpfpm composer install

# clone the default widgets
source clone_widgets.sh

# install widgets and run tests
source run_tests.sh
