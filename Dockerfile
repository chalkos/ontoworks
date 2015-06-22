FROM centos:latest
MAINTAINER Bruno Ferreira "docker@chalkos.net"

# Before building, this needs to be changed to whatever UID and GID
# the host is using for this file
# to get the UID use: ls -n Dockerfile | cut -d' ' -f3
# to get the GID use: ls -n Dockerfile | cut -d' ' -f4
ENV owUID=1000 owGID=100

# create group and user
RUN groupadd -fg$owGID ontoworks && useradd -u$owUID -g$owGID -ms /bin/bash ontoworks

# copy rails files
ADD . /home/ontoworks/webserver/
RUN /bin/bash -l -c "chown -R ontoworks /home/ontoworks/webserver"

# install dependencies, the last line are RVM depencencies
RUN yum makecache && yum install -y \
  curl \
  git \
  java-1.7.0-openjdk \
  postgresql-jdbc \
  sendmail \
  tar \
  unzip \
  zip \
  patch libyaml-devel glibc-headers autoconf gcc-c++ glibc-devel patch readline-devel zlib-devel libffi-devel openssl-devel make bzip2 automake libtool bison sqlite-devel

# switch to user
USER ontoworks
WORKDIR /home/ontoworks

# install RVM and jruby
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -L get.rvm.io | bash -s stable
RUN /home/ontoworks/.rvm/bin/rvm install jruby-1.7.16
RUN /home/ontoworks/.rvm/bin/rvm alias create default jruby-1.7.16
RUN echo 'gem: --no-ri --no-rdoc' > /home/ontoworks/.gemrc

# install rails & co.
RUN /bin/bash -l -c "gem install rails -v 4.2.0"
RUN /bin/bash -l -c "gem install puma -v 2.11.1"
RUN /bin/bash -l -c "gem install rake -v 10.4.2"
RUN /bin/bash -l -c "gem install bundler -v 1.7.3"

# webserver configuration
WORKDIR /home/ontoworks/webserver
RUN /bin/bash -l -c "bundle install"

# production configuration
ENV RAILS_ENV=production

# docker configuration
ENTRYPOINT ["/home/ontoworks/webserver/docker-entrypoint.sh"]


# NOTES
#
# shell is /bin/bash
#
# dockerfile best practices
# https://docs.docker.com/articles/dockerfile_best-practices/
#
# information on installing rvm
# https://github.com/vallard/docker/blob/master/rails/Dockerfile
#
# RUN /bin/bash -l -c "rake RAILS_ENV=production db:create db:migrate assets:precompile"
