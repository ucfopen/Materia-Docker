# ./channelSay "Building $BUILD_URL"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
#USE_SUDO=''
# USE_SUDO='sudo'

# make sure the db is clean and clear
$USE_SUDO docker-compose run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env FUEL_ENV=test php oil r admin:destroy_everything --quiet

# isntall everything
$USE_SUDO docker-compose run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env FUEL_ENV=test php oil r install --install_widgets=false --skip_prompts=true

# install all widget files in tmp
$USE_SUDO docker-compose run --rm phpfpm bash -c 'env FUEL_ENV=test php oil r widget:install fuel/app/tmp/widget_packages/*.wigt'

# run tests!
$USE_SUDO docker-compose run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env SKIP_BOOTSTRAP_TASKS=true php oil test

#cd /home/lst/Desktop/materia-docker/app
#jasmine-node --coffee --verbose --captureExceptions spec/
