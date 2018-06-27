#!/bin/bash
set -e
# INSTALLS WIDGETS FROM EXISTING WIGT FILE
# place .wigt files in app/fuel/app/tmp/widget_packages/
# run with: ./install_widget.sh adventure.wigt
# this does support globs, but you have to quote them so they arent processed in your term
# run w wildcards: ./install_widget.sh '*.wigt'  OR  ./install_widget.sh 'popup*.wigt'

die () {
    echo >&2 "$@"
    exit 1
}

[ "$#" -gt 0 ] || die "argument error: 1 or more widget files required: enigma.wigt or a quoted glob: '*.wigt'"

echo "Installing widgets: ./app/fuel/app/tmp/widget_packages/$1"
docker-compose run --rm phpfpm bash -c 'php oil r widget:install fuel/app/tmp/widget_packages/'$1
