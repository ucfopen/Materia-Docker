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

WORKDIR /var/www/html

# Define default command.
CMD ["bash"]
