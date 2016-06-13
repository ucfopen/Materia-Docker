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
	echo ==============================================================================
	echo "skipping inital install"
	echo "app/fuel/app/config/development/migrations.php exists!"
	echo "remove it or run 'docker-compose run --rm phpfpm php oil r admin:destroy_everything'"
	echo ==============================================================================
	exit
fi

docker-compose run --rm phpfpm bash -c '/wait-for-it.sh mysql:3306 -t 20 -- php oil r install --install_widgets=false --skip_prompts=true'

source clone_widgets.sh

docker-compose run --rm phpfpm bash -c 'php oil r widget:install fuel/app/tmp/widget_packages/*.wigt'

# # install all the needed npm stuff
$USE_SUDO docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm node npm install

# # compile js and css
$USE_SUDO docker-compose -f docker-compose.yml -f docker-compose.admin.yml run --rm node gulp js css hash

# run that beast
echo Materia will be on port 80 at $(docker-machine ip default)
echo Run: docker-compose run --rm node gulp js css
echo or just
echo docker-compose up
