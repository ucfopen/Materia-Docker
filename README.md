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
3. install docker stuffs `brew install docker docker-machine docker-compose`
4. check for an existing docker machine with `docker-machine ls`
5. if not there, make a docker machine called *default* `docker-machine create -d virtualbox default`
6. set env variables so docker commands will work in terminal `eval "$(docker-machine env default)"`

### AWS Container Repository
1. Install aws command line tools `brew install awscli`
2. Set up your aws creds - obtain your **super secret** key/secret pair
3. Run `aws configure` and give it your secrets.  Enter `us-east-1` for region
4. Run `aws ecr get-login`
5. Run the output of the previous command to log in
6. This log in is temporary, and may need to be run again to download more docker images

### Setting up the Development Materia Docker Server

1. Make sure you Github ssh keys and Clu ssh keys are set up

2. Clone this repo into a directory anywhere in your **home** directory.
	```
	git clone git@***REMOVED***:materia/materia-docker.git ~/my_projects/materia_docker
	```

3. Run the first run script to build and prepare the server.

	```
	./firstrun.sh
	```
	It'll clone Materia, build the docker containers, and install all the dependencies.

### Common Dev Commands

* Run the server
	```
	docker-compose up
	```
* Compile the coffeescript and sass
	```
	docker-compose run --rm node gulp js css hash
	```
* Install composer libraries
	```
	docker-compose run --rm phpfpm composer install
	```
* Clone main materia widgets packages into fuel/app/tmp/widget_packages/*.wigt
	```
	./clone_widgets.sh
	```
* Install all Widgets in fuel/app/tmp/widget_packages/*.wigt
	```
	./install_widgets.sh
	```

* What ip address my server on?
	```
	docker-machine ip default
	```
* Installing widgets: Copy the widget file you want to install into **app/fuel/app/tmp/** and then run **install_widget.sh** passing the name of the widget file to install. Example:
   
    ```
    cp my_widget.wigt ~/my_projects/materia_docker/app/fuel/app/tmp
    cd ~/my_projects/materia_docker
    ./install_widget my_widget.wigt
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

If you get a *no space left on dev* error: Remove the machine with `docker-machine rm default` then start over from step 3 in OSX Docker Setup. You may need to attempt the rm command twice before it removes the VM successfully.)

When running fuelphp's install, you may need to make sure the fuel/app/config/dev/migrations.php file is in sync with your database.  If it's a new database, just delete the file.

Use `docker-machine ip` and use the database user info from the docker-composer.yml

Run oil commands: `docker-compose run --rm phpfpm php oil ......`

You can clone the repositories from the repositories from the materia widget config:
`./clone_widgets.sh`

Then install them all
`./install_widget '*.wigt'`

### Optional

The `eval "$(docker-machine env default)"` command is somewhat tedious. Add the following in your *~/.bash_profile* and from now on you can simply type `dmenv default`:

```
function dmenv () {
  eval $(docker-machine env $1);
}
```


### Building new docker images

Use the `build_xxxx.sh` scripts to build new versions of the images.  You'll need write access to the aws docker repository to upload them.
