# ./channelSay "Building $BUILD_URL"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_DIR="$DIR/app/fuel/packages/materia/vendor/widget/source"
# USE_SUDO=''
USE_SUDO='sudo'
# ghprbActualCommit=maverick/clean-up-the-damn-widget-installer

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

# run the tasks normaly run in phpunit bootstrap that we have to skip
# because we're going to clone the widgets from jenkins
$USE_SUDO docker-compose run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env FUEL_ENV=test php oil r install --install_widgets=false --skip_prompts=true

# clone and install the widgets from the widget config
for i in $(grep -oh '\<git.*\.git\>' $DIR/app/fuel/packages/materia/config/widgets.php); do
	rm -rf $DIR/app/fuel/app/tmp/widget
	git clone $i --depth=1 $DIR/app/fuel/app/tmp/widget
	$USE_SUDO docker-compose run --rm phpfpm bash -c 'env FUEL_ENV=test php oil r widget:install fuel/app/tmp/widget/_output/*.wigt'
	rm -rf $DIR/app/fuel/app/tmp/widget
done

# run tests!
$USE_SUDO docker-compose run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env SKIP_BOOTSTRAP_TASKS=true php oil test

#cd /home/lst/Desktop/materia-docker/app
#jasmine-node --coffee --verbose --captureExceptions spec/
