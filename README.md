# Materia Docker Container

Materia set up using as docker containers as close to standard as possible.

## Container Architecture

 1. nginx serves materia on port 80 and static files on 8080
 3. phpfpm runs php - served by the nginx container on port 80
 4. mysql holds all the data
 5. node compiles all the assets and shuts down

## Setup

###  OSX Docker Setup
1. install virtualbox v.5+
2. update brew `brew update`
3. install docker stuffs `brew install docker docker-machine docker-compose`
5. make docker vm called *default* `docker-machine create -d virtualbox default`
6. set env variables so docker commands will work in terminal `eval "$(docker-machine env default)"`

### Setting up the stack and app

1. clone materia into app/ `git clone git@github.com:ucfcdl/Materia.git app`
2. get the deploy keys from your boss
3. install npm_modules for gulp `docker-compose run node npm install`
4. compile assets with gulp `docker-compose run node gulp js css hash`
5. install composer modules `docker-compose run phpfpm composer install`
6. run install task `docker-compose run phpfpm php oil r install` (errors? clear fuel/app/config/development/migrations.php)
7. get the ip of the our default docker machine `docker-machine ip default`
8. Run the server stack `docker-compose up`


The site is accessible in your browser at the ip address of the vm `docker-machine ip`

You can access mysql by opening up port 3306 in docker-composer.yml and restarting the containers. Use `docker-machine ip` and use the database user info from the docker-composer.yml

Run oil commands: `docker-compose run phpfpm php oil ......`

You cannot run php oil commands from your host machine.

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