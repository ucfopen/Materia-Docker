# place widget files in app/fuel/app/tmp/
# run with: ./install_widget.sh adventure.wigt
# in this case adventure.wigt is located in tmp
# this does not support globs like *.wigt
docker-compose run phpfpm sh -c 'php oil r widget:install -u -f /var/www/html/fuel/app/tmp/'$1
