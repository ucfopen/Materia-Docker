#!/bin/bash
# ./channelSay "Building $BUILD_URL"
# ghprbActualCommit=maverick/clean-up-the-damn-widget-installer
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
USE_SUDO='sudo' # we run these via sudo on linux, osx is better w/o it

if [ ! -d $DIR/app ]; then
	git clone git@github.com:ucfcdl/Materia.git app
fi

# checkout app
cd $DIR/app
git fetch --all
git reset --hard
#git checkout $GIT_COMMIT
git checkout $ghprbActualCommit

# clean migration files
rm -f $DIR/app/fuel/app/config/development/migrations.php
rm -f $DIR/app/fuel/app/config/test/migrations.php

cd $DIR

# stop and remove docker containers
$USE_SUDO docker-compose stop
$USE_SUDO docker-compose rm -vf

# update docker containers
git reset --hard
git pull

$USE_SUDO docker-compose build mysql
$USE_SUDO docker-compose build phpfpm

$USE_SUDO docker-compose run --rm phpfpm composer install

# clone the default widgets
source clone_widgets.sh

# install widgets and run tests
source run_tests.sh

#cd /home/lst/Desktop/materia-docker/app
#jasmine-node --coffee --verbose --captureExceptions spec/
