#!/bin/bash
set -e

# make a place to put .wigt files
if [ ! -d app/fuel/app/tmp/widget_packages ]; then
	mkdir app/fuel/app/tmp/widget_packages
fi

# clear any previous .wigt files
rm -rf app/fuel/app/tmp/widget_packages/*

# fresh clone of all configured widgets and copy .wigt files to be installed
for i in $(grep -oh '\<git.*\.git\>' app/fuel/packages/materia/config/widgets.php); do
	rm -rf app/fuel/app/tmp/widgetsrc
	git clone $i --depth=1 app/fuel/app/tmp/widgetsrc
	cp app/fuel/app/tmp/widgetsrc/_output/*.wigt app/fuel/app/tmp/widget_packages/
	rm -rf app/fuel/app/tmp/widgetsrc
done
