#!/bin/bash -l

# this file is used by docker but can be used
# outside of docker for everything but production

if [ "$1" = 'start' ]; then
  source .env
  ./railsStart "$2" "$3" "$4"
elif [ "$1" = 'reset_development' ]; then
  rake db:drop db:create db:migrate schema:load db:seed assets:clobber
  rm -rf db/tdb/*
elif [ "$1" = 'reset_production' ]; then
  echo "export SECRET_KEY_BASE=$(rake secret)" > .env
  source .env
  rake db:drop db:create db:migrate schema:load assets:precompile
  rm -rf db/tdb/*
elif [ "$1" = 'reset_logs' ]; then
  > log/development.log
  > log/production.log
else
  exec "$@"
fi
