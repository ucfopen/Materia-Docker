#!/bin/bash
#!/bin/bash
#######################################################
# ABOUT THIS SCRIPT
#
# Initializes a new Materia environment in Docker

# 1. Clone materia into ./app/
# 2. Get a local copy of the current Docker Images
# 3. Build any Docker Images we need to
# 4. Create the containers
# 5. Install php composer dependencies
# 6. Clean the migration files
# 7. Run Materia installer
# 8. Install any widgets in fuel/app/tmp/widget_packages/
# 9. Use Yarn to install js dependencies
# 10. Use Yarn to build js and css
#
# If you find you really need to burn everything down
# Run "docker-compose down" to get rid of all containers
#
# Materia only comes with 2 bare bones widgets for unit tests
# Build your own using ./run_widgets_build.sh
#######################################################
set -e

NODE_DC_COMMAND="docker-compose -f docker-compose.yml -f docker-compose.admin.yml"
DOCKER_IP="localhost"

if [ ! -d app ]; then
	git clone https://github.com/ucfcdl/Materia.git app
fi

if [ ! -d materia-thumbnail-generator ]; then
	git clone https://clu.cdl.ucf.edu/serverless/materia-thumbnail-generator.git
fi

if [ ! -d app ]; then
	echo "It looks like the app directory is empty"
	exit
fi

# Use docker or set up the docker-machine environment
if hash docker 2>/dev/null; then
	echo "using docker directly"
else
	echo "using docker-machine"
	eval $(docker-machine env default)
	DOCKER_IP="$(docker-machine ip default)"
fi

# Login to awscli?
if hash aws 2>/dev/null; then
	echo "awscli detected... attempting to log in"
	$(aws ecr get-login --no-include-email)
else
	echo "awscli not detected you may have difficulty pulling docker images without it installed and setup.  Check README.md"
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

docker-compose run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- composer oil-install-quiet

docker-compose run --rm phpfpm bash -c 'php oil r widget:install fuel/app/tmp/widget_packages/*.wigt'

source run_assets_build.sh

# run that beast
# Use docker or set up the docker-machine environment
echo -e "Materia will be hosted on \033[32m$DOCKER_IP\033[0m"
echo -e "\033[1mBuild Assets:\033[0m ./run_assets_build.sh"
echo -e "\033[1mRun an oil comand:\033[0m ./run.sh php oil r  widget:show_engines"
echo -e "\033[1mRun the web app:\033[0m docker-compose up"
