#!/bin/bash
set -e

NODE_DC_COMMAND="docker-compose -f docker-compose.yml -f docker-compose.admin.yml"
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

docker-compose run --rm phpfpm bash -c '/wait-for-it.sh mysql:3306 -t 20 -- php oil r install --skip_prompts=true --skip_configuration_wizard'

# source clone_widgets.sh

docker-compose run --rm phpfpm bash -c 'php oil r widget:install fuel/app/tmp/widget_packages/*.wigt'

# # install all the needed npm stuff
$USE_SUDO $NODE_DC_COMMAND run --rm node yarn install --pure-lockfile --force

# # compile js and css
$USE_SUDO $NODE_DC_COMMAND run --rm node yarn run assets

# run that beast
# Use docker or set up the docker-machine environment
echo -e "Materia will be hosted on \033[32m$DOCKER_IP\033[0m"
echo -e "\033[1mRun gulp:\033[0m $NODE_DC_COMMAND run --rm node gulp js css hash"
echo -e "\033[1mRun an oil comand:\033[0m docker-compose run --rm phpfpm php oil r"
echo -e "\033[1mRun the web app:\033[0m docker-compose up"

