# ./channelSay "Building $BUILD_URL"

DOCKER_DIR="/home/lst/Desktop/materia-docker"

# checkout app
cd $DOCKER_DIR/app
git fetch --all
git reset --hard
#git checkout $GIT_COMMIT
git checkout $ghprbActualCommit

# clean widgets out
rm -rf $DOCKER_DIR/app/fuel/packages/materia/vendor/widget/source/*

# clone widgets based on the widgets in fuel/app/config/widgets.php
cd $DOCKER_DIR/app/fuel/packages/materia/vendor/widget/source
for i in $(grep -oh '\<git.*\.git\>' ../../../config/widgets.php); do git clone --depth 2 $i; done

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

sudo docker-compose run phpfpm  /wait-for-it.sh mysql:3306 -t 20 -- composer install

# run the tasks normaly run in phpunit bootstrap that we have to skip
# because we're going to clone the widgets from jenkins
sudo docker-compose run phpfpm -e FUEL_ENV=test php oil r admin:clear_cache
sudo docker-compose run phpfpm -e FUEL_ENV=test php oil r admin:clear_cache
sudo docker-compose run phpfpm -e FUEL_ENV=test php oil r admin:setup_migrations
sudo docker-compose run phpfpm -e FUEL_ENV=test php oil r admin:populate_roles
sudo docker-compose run phpfpm -e FUEL_ENV=test php oil r admin:populate_semesters
sudo docker-compose run phpfpm -e FUEL_ENV=test php oil r admin:create_default_users

# install widgets from the source dir we filled up earlier
sudo docker-compose run phpfpm /bin/sh -c 'find fuel/packages/materia/vendor/widget/source/*/_output/*.wigt -exec env FUEL_ENV=test php oil r widget:install -u -f {} \;'

# run tests!
sudo docker-compose run phpfpm -e SKIP_BOOTSTRAP_TASKS=true php oil test

#cd /home/lst/Desktop/materia-docker/app
#jasmine-node --coffee --verbose --captureExceptions spec/
