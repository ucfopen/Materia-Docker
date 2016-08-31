#!/bin/bash
set -e
eval $(docker-machine env default)

if [ ! -d app ]; then
	git clone git@github.com:ucfcdl/Materia.git app
fi

if [ ! -d app ]; then
	echo "It looks like the app directory is empty"
	exit
fi

docker-compose pull

# create and migrate the database
docker-compose build

# create the contaners and setup networking
docker-compose create

# install composer deps
docker-compose run --rm phpfpm composer install

# run install if migration file is not there
# sometimes it's left behind when copying or re-installing
# it needs to be removed for install to work correctly
if [ -f  app/fuel/app/config/development/migrations.php ]; then
	rm -f app/fuel/app/config/development/migrations.php
fi

docker-compose run --rm phpfpm ash -c '/wait-for-it.sh mysql:3306 -t 20 -- php oil r install --install_widgets=false --skip_prompts=true'

source cmd_widgets_clone.sh

docker-compose run --rm phpfpm ash -c 'php oil r widget:install fuel/app/tmp/widget_packages/*.wigt'

# # install all the needed npm stuff
$USE_SUDO docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm node npm install

# # compile js and css
$USE_SUDO docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm node gulp js css hash

# run that beast
echo ===================================
echo All Set, heres some common commands
echo ===================================
echo Compile assets: ./cmd_gulp_once.sh
echo Run tests: ./cmd_tests_run.sh
echo Install widgets: ./cmd_widget_install.sh
echo Run server: docker-compose up
