#!/bin/bash
eval $(docker-machine env default)

USE_SUDO=''
# USE_SUDO='sudo'

if [ ! -d app ]; then
	git clone git@github.com:ucfcdl/Materia.git app
fi

if [ ! -d app ]; then
	echo "It looks like the app directory is empty"
	exit
fi

# create and migrate the database
$USE_SUDO docker-compose build

# install all the needed npm stuff
$USE_SUDO docker-compose run --rm node npm install

# compile js and css
$USE_SUDO docker-compose run --rm node gulp js css hash

# install composer deps
$USE_SUDO docker-compose run --rm phpfpm composer install

# run install if migration file is not there
# sometimes it's left behind when copying or re-installing
# it needs to be removed for install to work correctly
if [ -f  app/fuel/app/config/development/migrations.php ]; then
	echo ==============================================================================
	echo "skipping inital install"
	echo "app/fuel/app/config/development/migrations.php exists!"
	echo "remove it or run '$USE_SUDO docker-compose run -rm phpfpm php oil r admin:destroy_everything'"
	echo ==============================================================================
	exit
fi

$USE_SUDO docker-compose run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- php oil r install --install_widgets=false --skip_prompts=true

# clone and install the widgets from the widget config
for i in $(grep -oh '\<git.*\.git\>' app/fuel/packages/materia/config/widgets.php); do
	rm -rf app/fuel/app/tmp/widget
	git clone $i --depth=1 app/fuel/app/tmp/widget
	$USE_SUDO docker-compose run --rm phpfpm bash -c 'php oil r widget:install fuel/app/tmp/widget/_output/*.wigt'
	rm -rf app/fuel/app/tmp/widget
done

# run that beast
echo Materia will be on port 80 at $(docker-machine ip default)
echo Run: $USE_SUDO docker-compose run --rm node gulp js css
echo or just
echo $USE_SUDO docker-compose up
