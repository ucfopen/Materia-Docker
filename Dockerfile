FROM php:5.6.8-fpm
MAINTAINER Ian Turgeon

RUN apt-get update && apt-get install -y \
  zlib1g-dev

RUN docker-php-ext-install pdo pdo_mysql zip

# hack to let php write to the shared disk with boot2docker shares
RUN usermod -u 1000 www-data
