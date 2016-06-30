#!/bin/bash
set -e

# make sure the db is clean and clear
docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
 run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- php oil r admin:destroy_everything --quiet

# isntall everything
docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
 run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- php oil r install --install_widgets=false --skip_prompts=true

# install all widget files in tmp
docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
 run --rm phpfpm bash -c 'php oil r widget:install fuel/app/tmp/widget_packages/*.wigt'

# run tests!
docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
 run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env SKIP_BOOTSTRAP_TASKS=true php oil test --coverage-html=coverage --coverage-clover=coverage.xml --coverage-text=coverage.txt

#cd /home/lst/Desktop/materia-docker/app
#jasmine-node --coffee --verbose --captureExceptions spec/
