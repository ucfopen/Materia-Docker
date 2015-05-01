# Materia Docker Container

Materia set up using as docker containers as close to standard as possible.

## Architecture

 1. NginxContainer serves materia on port 80 (passed through nginx)
 2. NginxContainer serves static files on port 8080
 3. PHPFPM container executes materia code served by nginx's port 80 requests
 4. MYSQL container connects to phpfpm and holds all the data

## Setup

1. clone materia into app/ `git clone git@github.com:ucfcdl/Materia.git app`
2. clone widgets into app/widgets
3. install npm for materia `cd app && npm install`
4. compile coffeescript and sass `gulp js css hash`
5. get composer `curl -sS https://getcomposer.org/installer | php`
6. install php packages `composer update`
7. start the docker containers `docker-compose up`
8. open bash in the php container `docker-compose run --entrypoint /bin/bash php`
9. migrate and install `php oil r install widget_path="widgets/*/_output/*.wigt" -u -f`

The site is accessible in your browser at the ip address of the vm `boot2docker ip`

You can access mysql by opening up port 3306 in docker-composer.yml and restarting the containers. Use `boot2docker ip` and use the database user info from the docker-composer.yml

You cannot run php oil commands from your host machine without changing database configuration.  (to do so, change the db connection host to the boot2docker ip value)

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