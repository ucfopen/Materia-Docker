#!/bin/bash
eval $(docker-machine env default)
git clone git@github.com:ucfcdl/Materia.git app

# create and migrate the database
docker-compose build

# install all the needed npm stuff
docker-compose run node npm install

# compile js and css
docker-compose run node gulp js css hash

# install composer deps
docker-compose run phpfpm composer install

# run install if migration file is not there
if [ -f  app/fuel/app/config/development/migrations.php ]; then
	echo ==============================================================================
	echo skipping inital install
	echo app/fuel/app/config/development/migrations.php exists!
	echo remove it or run oil r admin:destroy_everything
	echo ==============================================================================
else
	# run oil install once mysql is ready
	docker-compose run phpfpm /wait-for-it.sh mysql:3306 -t 20 -- php oil r install -u -f
fi

# run that beast
echo Materia will be on port 80 at $(docker-machine ip default)
echo Run: $ docker-compose run node gulp js css
echo or just
echo $ docker-compose up
