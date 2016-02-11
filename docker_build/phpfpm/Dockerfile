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

# make sure en_US.UTF-8 is on the system
# RUN locale-gen en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV LC_ALL en_US.UTF-8

# RUN locale-gen en_US.UTF-8 en_us
# RUN dpkg-reconfigure locales
# RUN dpkg-reconfigure locales
# RUN locale-gen C.UTF-8
# RUN /usr/sbin/update-locale LANG=C.UTF-8

RUN mkdir /root/.ssh/
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan ***REMOVED*** >> /root/.ssh/known_hosts

# Clean up the image
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# hack to let php write to the shared disk with boot2docker shares
RUN usermod -u 1000 www-data
