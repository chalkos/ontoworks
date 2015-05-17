FROM centos:latest
MAINTAINER Bruno Ferreira "docker@chalkos.net"

RUN useradd -ms /bin/bash ontoworks
USER ontoworks

# NOTES
#
# shell is /bin/bash
#
# dockerfile best practices
# https://docs.docker.com/articles/dockerfile_best-practices/
#
# information on installing rvm
# https://github.com/vallard/docker/blob/master/rails/Dockerfile
