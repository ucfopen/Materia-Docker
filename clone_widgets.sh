#!/bin/bash

# CLONE AND BUILD WIDGETS
# This script will dig through ./clone_widgets_list.txt and
# clone any repositories listed there, build them, and copy
# the widget package into app/fuel/app/tmp/widget_packages/
# Runs in the context of your current bash, so you'll
# need node and yarn installed wherever you run this script

set -e

# make a place to put .wigt files
if [ ! -d app/fuel/app/tmp/widget_packages ]; then
	mkdir app/fuel/app/tmp/widget_packages
fi

# clear any previous .wigt files
rm -rf app/fuel/app/tmp/widget_packages/*

echo Reading widget list from clone_widgets_list.txt
WIDGETS=$(grep -oh '\<git.*\.git\>' ./clone_widgets_list.txt)

# Hack to work with goofy old gulp code that had devMateria dependencies
mkdir -p app/fuel/app/backend
echo "{}" > app/fuel/app/backend/config.json
# END HACK

# fresh clone of all configured widgets and copy .wigt files to be installed
ALL=false
for i in ${WIDGETS[@]}; do
	if [[ "$ALL" = false ]]; then
		echo -n "Clone and build $i? [y,n,a,q]: "
		read INPUT

		# QUIT
		if [[ "$INPUT" == 'q' ]]; then
			break
		fi

		# DONT CLONE
		if [[ "$INPUT" == 'n' ]]; then
			continue
		fi

		# CLONE ALL
		if [[ "$INPUT" == 'a' ]]; then
			ALL=true
			BRANCH='deploy_prod'
		fi

		# DEFAULT "y"
		# Pick a branch
		echo -n "Enter a branch, tag, or commit (default: deploy_prod): "
		read BRANCH
		if [ -z ${BRANCH} ]; then
			BRANCH=deploy_prod
		fi
	fi

	rm -rf app/fuel/app/tmp/widgetsrc
	mkdir -p app/fuel/app/tmp/widgetsrc
	echo "Cloning $i ($BRANCH)..."
	set +e
	CLONE_OUTPUT=$(git clone -b $BRANCH --single-branch $i --depth=1 app/fuel/app/tmp/widgetsrc 2>&1)

	if (( $? > 0 )); then
		echo "*** ERROR CLONING ***"
		echo -e "$CLONE_OUTPUT"
		continue
	fi

	cd app/fuel/app/tmp/widgetsrc/
	echo "Installing yarn deps..."
	INSTALL_OUTPUT=$(yarn install --no-progress 2>&1)
	if (( $? > 0 )); then
		echo "*** ERROR RUNNING YARN INSTALL ***"
		echo -e "$INSTALL_OUTPUT"
		continue
	fi

	echo "Running yarn build..."
	BUILD_OUTPUT=$(yarn build 2>&1)
	if (( $? > 0 )); then
		echo "*** ERROR RUNNING YARN BUILD ***"
		echo -e "$BUILD_OUTPUT"
		continue
	fi

	set -e
	cd ../../../../../
	cp app/fuel/app/tmp/widgetsrc/.build/**/*.wigt app/fuel/app/tmp/widget_packages/
	rm -rf app/fuel/app/tmp/widgetsrc
	echo "DONE"
done

# Hack to work with goofy old gulp code that had devMateria dependencies
rm -rf app/fuel/app/backend
# END HACK
