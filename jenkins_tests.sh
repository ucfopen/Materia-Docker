# ./channelSay "Building $BUILD_URL"

DOCKER_DIR="/home/lst/Desktop/materia-docker"
SOURCE_DIR="$DOCKER_DIR/app/fuel/packages/materia/vendor/widget/source"

if [ ! -d $DOCKER_DIR/app ]; then
	git clone git@github.com:ucfcdl/Materia.git app
fi

# checkout app
cd $DOCKER_DIR/app
git fetch --all
git reset --hard
#git checkout $GIT_COMMIT
git checkout $ghprbActualCommit


# diff the widget file
# $? is 1 if everythings the same, 2 if there's no file, and 0 if there is a diff
# so if the command outputs anything but 1, update our cache and clone
config_changed=$(grep -vFxf $DOCKER_DIR/app/fuel/packages/materia/config/widgets.php $SOURCE_DIR/widgets.php)
if [ $? -ne 1 ]; then
	# clean widgets out
	rm -rf $DOCKER_DIR/app/fuel/packages/materia/vendor/widget/source/*

	cd $DOCKER_DIR/app/fuel/packages/materia/vendor/widget/source
	for i in $(grep -oh '\<git.*\.git\>' ../../../config/widgets.php); do git clone $i; done
	# update our cached copy
	cp $DOCKER_DIR/app/fuel/packages/materia/config/widgets.php $SOURCE_DIR/widgets.php

else
	for d in $SOURCE_DIR/* ; do
		[ -d "${d}" ] || continue # skip if not a directory
		cd $d
		git reset --hard
		git pull
	done
fi

cd $DOCKER_DIR/app

# clean migration files
rm -f $DOCKER_DIR/app/fuel/app/config/development/migrations.php
rm -f $DOCKER_DIR/app/fuel/app/config/test/migrations.php 

cd $DOCKER_DIR

# stop and remove docker containers
sudo docker-compose stop
sudo docker-compose rm -vf

# update docker containers
git reset --hard
git pull
sudo docker-compose build mysql
sudo docker-compose build phpfpm

sudo docker-compose run phpfpm composer install

# run the tasks normaly run in phpunit bootstrap that we have to skip
# because we're going to clone the widgets from jenkins
sudo docker-compose run phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env FUEL_ENV=test php oil r admin:clear_cache
sudo docker-compose run phpfpm env FUEL_ENV=test php oil r admin:setup_migrations
sudo docker-compose run phpfpm env FUEL_ENV=test php oil r admin:populate_roles
sudo docker-compose run phpfpm env FUEL_ENV=test php oil r admin:populate_semesters
sudo docker-compose run phpfpm env FUEL_ENV=test php oil r admin:create_default_users

# install widgets from the source dir we filled up earlier
sudo docker-compose run phpfpm /bin/sh -c 'find fuel/packages/materia/vendor/widget/source/*/_output/*.wigt -exec env FUEL_ENV=test php oil r widget:install -u -f {} \;'

# run tests!
sudo docker-compose run phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env SKIP_BOOTSTRAP_TASKS=true php oil test

#cd /home/lst/Desktop/materia-docker/app
#jasmine-node --coffee --verbose --captureExceptions spec/

sudo docker stop $(sudo docker ps -a -q)
sudo docker rm $(sudo docker ps -a -q)
