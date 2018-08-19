# Materia Docker Container

Materia set up using as docker containers as close to standard as possible.

## Container Architecture

 1. nginx serves materia on port 80 and static files on 8080
 3. phpfpm runs php - served by the nginx container on port 80
 4. mysql holds all the data
 5. memcached holds session data and cache
 6. node compiles all the assets and shuts down

## Setup

Clone repo and execute `./run_first.sh`

### Common Dev Commands

* Run the server
	```
	docker-compose up
	```
* Compile the coffeescript and sass
	```
	./run_assets_build.sh
	```
* Install composer libraries
	```
	docker-compose run --rm phpfpm composer install
	```
* Clone main materia widgets packages into fuel/app/tmp/widget_packages/*.wigt
	```
	./run_widgets_build.sh
	```
* Install all Widgets in fuel/app/tmp/widget_packages/*.wigt
	```
	./run_widgets_install.sh '*.wigt'
	```
* Installing widgets: Copy the widget file you want to install into **app/fuel/app/tmp/widget\_packages/** and then run **install_widget.sh** passing the name of the widget file to install. Example:

    ```
    cp my_widget.wigt ~/my_projects/materia_docker/app/fuel/app/tmp
    cd ~/my_projects/materia_docker
    ./run_widgets_install.sh my_widget.wigt
    ```
* Installing test widgets?
    ```
    traverse to app/fuel/packages/materia/test/widget_source/
    Update test widgets as desired.
    traverse into the widget folder.
    read build instructions in that widget's README.md
    Note: these widget are necessary when running run_tests.sh
    ```
### Default User Accounts

If you wish to log into materia, there are 2 default accounts created for you.

* Author account:
	* Username: `~author`
	* Password: `kogneato`
* Student account:
	* Username: `~student`
	* Password: `kogneato`

### Troubleshooting

#### Table Not Found

When running fuelphp's install, it uses fuel/app/config/development/migrations.php file to know the current state of your database. Fuel assumes this file is truth, and won't create tables even on an empty database. You probably need to delete the file and run the setup scripts again.

#### No space left on dev error

If you get a *no space left on dev* error: Remove the machine with `docker-machine rm default` then start over from step 3 in OSX Docker Setup. You may need to attempt the rm command twice before it removes the VM successfully.)

Run oil commands: `docker-compose run --rm phpfpm php oil ......`

You can clone the repositories from the repositories from the materia widget config:
`./run_build_widgets.sh`

Then install them all
`./run_widgets_install.sh '*.wigt'`

### Building new docker images

Use the `build_xxxx.sh` scripts to build new versions of the images.  You'll need write access to the aws docker repository to upload them.
