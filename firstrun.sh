#!/bin/bash
set -e

DOCKER_IP="localhost"
# Use docker or set up the docker-machine environment
if hash docker 2>/dev/null; then
	echo "using docker directly"
else
	echo "using docker-machine"
	eval $(docker-machine env default)
	DOCKER_IP="$(docker-machine ip default)"
fi

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

docker-compose run --rm phpfpm bash -c '/wait-for-it.sh mysql:3306 -t 20 -- php oil r install --skip_install_widgets --skip_prompts=true --skip_configuration_wizard'

# source clone_widgets.sh

docker-compose run --rm phpfpm bash -c 'php oil r widget:install fuel/app/tmp/widget_packages/*.wigt'

# # install all the needed npm stuff
$USE_SUDO docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm node yarn --pure-lockfile --force

# # compile js and css
$USE_SUDO docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm node gulp js css hash

# run that beast
# Use docker or set up the docker-machine environment
echo Materia will be hosted on $DOCKER_IP
echo Run gulp: docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm node gulp js css hash
echo Run an oil comand: docker-compose run --rm phpfpm php oil r
echo Run the web app: docker-compose up
