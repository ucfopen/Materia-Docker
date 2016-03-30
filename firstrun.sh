#!/bin/bash
eval $(docker-machine env default)

if [ ! -d app ]; then
	git clone git@github.com:ucfcdl/Materia.git app
fi

if [ ! -d app ]; then
	echo "It looks like the app directory is empty"
	exit
fi

# create and migrate the database
docker-compose build

# install all the needed npm stuff
docker-compose run --rm node npm install

# compile js and css
docker-compose run --rm node gulp js css hash

# install composer deps
docker-compose run --rm phpfpm composer install

# run install if migration file is not there
if [ -f  app/fuel/app/config/development/migrations.php ]; then
	echo ==============================================================================
	echo "skipping inital install"
	echo "app/fuel/app/config/development/migrations.php exists!"
	echo "remove it or run 'docker-compose run -rm phpfpm php oil r admin:destroy_everything'"
	echo ==============================================================================
	exit
fi

# run oil install once mysql is ready
docker-compose run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- php oil r install -u -f

# run that beast
echo Materia will be on port 80 at $(docker-machine ip default)
echo Run: $ docker-compose run --rm node gulp js css
echo or just
echo $ docker-compose up
