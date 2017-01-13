#!/bin/bash
set -e

# lint all the php files before we spend much time doing anything
docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
 run --rm phpfpm bash -c 'find . -type f -iname "*.php" -not -path "./fuel/vendor/*" -not -path "./fuel/app/logs/*" -not -path "./fuel/core/*" -not -path "./fuel/packages/oil/*" -not -path "./fuel/packages/email/*" -not -path "./fuel/packages/auth/*" -not -path "./fuel/packages/orm/*" -not -path "./fuel/packages/parser/*" | xargs -n1 php -l'

# make sure the db is clean and clear
docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
 run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- php oil r admin:destroy_everything --quiet

# install everything
docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
 run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- php oil r install --install_widgets=false --skip_prompts=true

#Uncomment this if a failure to unpackage a widget has broken the test pipeline. Specific use case only.
#docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
# run --rm phpfpm bash -c -e 'rm /var/www/html/fuel/packages/materia/vendor/widget/test/* || true'

# install all widget files in tmp
docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
 run --rm phpfpm bash -c 'php oil r widget:install fuel/packages/materia/tests/widget_packages/*.wigt'

# run tests!
docker-compose -f docker-compose.yml -f docker-compose.admin.yml \
 run --rm phpfpm /wait-for-it.sh mysql:3306 -t 20 -- env SKIP_BOOTSTRAP_TASKS=true php oil test --coverage-html=coverage --coverage-clover=coverage.xml --coverage-text=coverage.txt

#cd /home/lst/Desktop/materia-docker/app
#jasmine-node --coffee --verbose --captureExceptions spec/
