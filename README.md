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
4. if not there, make a docker machine called *default* `docker-machine create -d virtualbox default`
5. set env variables so docker commands will work in terminal `eval "$(docker-machine env default)"`

### Setting up the Development Materia Docker Server

1. Make sure you Github ssh keys and Clu ssh keys are set up

2. Clone this repo into a directory anywhere in your **home** directory.
	```
	git clone git@***REMOVED***:materia/materia-docker.git ~/my_projects/materia_docker
	```

3. Copy your **Clu** ssh key to so Materia can use it to install widgets from Clu.  This is probably your id_rsa key.
	```
	cp ~/.ssh/id_rsa ~/my_projects/materia_docker/config/deploy_keys/widget_deploy_key
	```

4. Run the first run script to build and prepare the server.

	```
	./firstrun.sh
	```
	It'll clone Materia, build the docker containers, and install all the dependencies.

	If you see `Enter passphrase for key '/root/.ssh/id_rsa':` enter the password for the clu key password you copied in step 3 above.

### Common Dev Commands

* Run the server
	```
	docker-compose up
	```
* Compile the coffeescript and sass
	```
	docker-compose run -rm node gulp js css hash
	```
* Install composer libraries
	```
	docker-compose run -rm phpfpm composer install
	```
* What ip address my server on?
	```
	docker-machine ip default
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

Run oil commands: `docker-compose run phpfpm php oil ......`

You cannot run php oil commands from your host machine.

You can read the repositories from the widget config and clone the repositories:
cd `into app/fuel/app/tmp` and run `for i in $(grep -oh '\<git.*\.git\>' ../../packages/materia/config/widgets.php); do git clone $i; done`

Then install them all: `docker-compose run phpfpm  /bin/sh -c 'find fuel/app/tmp/*/_output/*.wigt -exec php oil r widget:install -u -f {} \;'`


If you have file permission issues, you may need to:

1. Edit `/etc/exports` add `/Users -mapall=[yourosxuser]:staff [boot2docker-vm-ip]`
2. Restart nfsd `sudo nfsd stop && sudo nfsd start`
3. create boot script in boot2docker vm `/var/lib/boot2docker/bootlocal.sh`
```
#|/bin/bash
sudo umount /Users
sudo /usr/local/etc/init.d/nfs-client start
sudo mount 192.168.59.3:/Users /Users -o rw,async,noatime,rsize=32768,wsize=32768,proto=tcp
```

### Optional

The `eval "$(docker-machine env default)"` command is somewhat tedious. Add the following in your *~/.bash_profile* and from now on you can simply type `dmenv default`:

```
function dmenv () {
  eval $(docker-machine env $1);
}
```
