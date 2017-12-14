# Materia Docker Container

Materia set up using as docker containers as close to standard as possible.

## Container Architecture

 1. nginx serves materia on port 80 and static files on 8080
 3. phpfpm runs php - served by the nginx container on port 80
 4. mysql holds all the data
 5. memcached holds session data and cache
 6. node compiles all the assets and shuts down

## Setup

###  OSX Docker Setup
1. install virtualbox v.5+
2. update brew `brew update`
3. install docker stuffs: Docker can be downloaded for [Mac](https://www.docker.com/docker-mac) or [Windows](https://www.docker.com/docker-windows), or through the Managed Software Center (recommended). Unlike `docker-machine`, no additional configuration is required.

### AWS Container Repository
1. Install aws command line tools `brew install awscli`
2. Set up your aws creds - obtain your **super secret** key/secret pair
3. Run `aws configure` and give it your secrets.  Enter `us-east-1` for region
4. Run `$(aws ecr get-login --no-include-emai)`
5. This log in is temporary, and may need to be run again to download more docker images

### Setting up the Development Materia Docker Server

1. Make sure you Github ssh keys and Clu ssh keys are set 

2. If you're using 2-factor authentication with Github, you'll have to set up a personal access token. [Instructions here.](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) On OSX, you can cache your GitHub password in the keychain. [Instructions here.](https://help.github.com/articles/caching-your-github-password-in-git/)

3. Clone this repo into a directory anywhere in your **home** directory.
	```
	git clone git@***REMOVED***:materia/materia-docker.git ~/my_projects/materia_docker
	```

4. Run the first run script to build and prepare the server.

	```
	./run_first.sh
	```
	It'll clone Materia, build the docker containers, and install all the dependencies.

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
