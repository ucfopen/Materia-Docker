FROM php:5.6.8-fpm
MAINTAINER Ian Turgeon

# System libs needed for php extensions
RUN apt-get update && apt-get install -y \
  git \
  libldap2-dev \
  libmcrypt-dev \
  libmemcached-dev \
  libpng-dev \
  libxml2-dev \
  zlib1g-dev

# PHP Exhensions
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu
RUN docker-php-ext-install \
	bcmath \
	gd \
	ldap \
	mbstring \
	mcrypt \
	mysql \
	pdo \
	pdo_mysql \
	xml \
	zip

# PECL Libraries
RUN pecl install memcached

# Make sure composer is installed globally
RUN bash -c "curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer"

# Clean up the image
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# hack to let php write to the shared disk with boot2docker shares
RUN usermod -u 1000 www-data
