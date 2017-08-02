#!/bin/bash
#######################################################
# ABOUT THIS SCRIPT
#
# Builds assets using the included node container
# DOCKER FOR MAC Doesn't support ssh agent forwarding
# So we have to run yarn on OSX instead
#######################################################
set -e

NODE_DC_COMMAND="docker-compose -f docker-compose.yml -f docker-compose.admin.yml"

# detect if we're on OSX
platform=`uname`
if [[ $platform == 'Darwin' ]]; then
	# on OSX, use the host machine
	cd app
	yarn install --pure-lockfile --force
	cd ..

elif [[ $platform == 'freebsd' ]]; then

	# install all the needed npm stuff, compile assets, and place them where needed
	$NODE_DC_COMMAND run --rm node yarn install --pure-lockfile --force
fi


