#!/bin/bash
# place .wigt files in app/fuel/app/tmp/widget_packages/
# run with: ./install_widget.sh adventure.wigt
# this does support globs, but you have to quote them so they arent processed in your term
# run w wildcards: ./install_widget.sh '*.wigt'  OR  ./install_widget.sh 'popup*.wigt'
docker-compose run --rm phpfpm sh -c 'php oil r widget:install /var/www/html/fuel/app/tmp/widget_packages/'$1
