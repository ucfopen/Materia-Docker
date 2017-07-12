#!/bin/bash
set -e

# If you have an issue with a broken widget package breaking this script, run the following to clear the widgets
# docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm phpfpm bash -c -e 'rm /var/www/html/fuel/packages/materia/vendor/widget/test/*'

# store the docker compose command to shorten the following commands
DC="docker-compose -f docker-compose.yml -f docker-compose.admin.yml"

# make sure the db is clean and clear
$DC run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- composer run destroy-everything

# install everything
$DC run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- composer run install-quiet

# install all widget files in tmp
$DC run --rm phpfpm composer run widgets-install-test

# run tests!
$DC run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env SKIP_BOOTSTRAP_TASKS=true composer run coverage

