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
4. make docker vm called *default* `docker-machine create -d virtualbox default`
5. set env variables so docker commands will work in terminal `eval "$(docker-machine env default)"`

### Setting up the stack and app

1. In the *materia-docker* directory clone materia into app/ `git clone git@github.com:ucfcdl/Materia.git app`
2. get the deploy keys from your boss and put them in *config/deploy_keys*
3. install npm_modules for gulp `docker-compose run node npm install` (errors? check troubleshooting below)
4. compile assets with gulp `docker-compose run node gulp js css hash`
5. install composer modules `docker-compose run phpfpm composer install`
6. run install task `docker-compose run phpfpm php oil r install` (errors? check troubleshooting below)
7. Run the server stack `docker-compose up`. Eventually the output will look like it hangs with `mysql_1` saying it's ready for connections - that means your docker machine is good to go!

The site is accessible in your browser at the ip address of the vm which you can get with `docker-machine ip default`

The terminal window running docker-compose is keeping your containers alive.  Ctrl-C will stop them and your app with it.

### Troubleshooting

If you get a *no space left on dev* error: Remove the machine with `docker-machine rm default` then start over from step 3 in OSX Docker Setup. You may need to attempt the rm command twice before it removes the VM successfully.)

When running fuelphp's install, you may need to make sure the fuel/app/config/dev/migrations.php file is in sync with your database.  If it's a new database, just delete the file.

Use `docker-machine ip` and use the database user info from the docker-composer.yml

Run oil commands: `docker-compose run phpfpm php oil ......`

You cannot run php oil commands from your host machine.

You can clone widgets using the host machine into app/fuel/app/tmp/ and run the following command to install them all: `docker-compose run phpfpm  /bin/sh -c 'find fuel/app/tmp/*/_output/*.wigt -exec php oil r widget:install -u -f {} \;'`


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