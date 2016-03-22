FROM node:4.2.2
MAINTAINER Ian Turgeon

RUN apt-get update && apt-get install -y \
  ruby

RUN gem install \
  sass

RUN npm install --global \
  bower \
  grunt-cli \
  gulp

# Clean up the image
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /var/www/html

# Define default command.
CMD ["bash"]
