#!/bin/bash -l

# this file is used by docker but can be used
# outside of docker for everything but production

# Builtin commands:
# start [max [heap [min]]] - start rails server
# reset_development - clean and prepare development environment
#                     (although docker container runs only in production)
# reset_production - clean and prepare a production environment
#                    (should only be used with docker)
# reset_logs - clear logs
# logs [environment=production] - show scrolling log (uses tail -f)


if [ "$1" = 'start' ]; then
  source .env
  ./railsStart $2 $3 $4

elif [ "$1" = 'reset_development' ]; then
  rake db:drop db:create db:migrate db:schema:load db:seed assets:clobber
  rm -rf db/tdb/*

elif [ "$1" = 'reset_production' ]; then
  echo "export SECRET_KEY_BASE=$(rake secret)" > .env
  echo "export CLASSPATH=/usr/share/java/postgresql-jdbc.jar" >> .env
  source .env
  rake db:drop db:create db:migrate db:schema:load assets:precompile
  rm -rf db/tdb/*

elif [ "$1" = 'reset_logs' ]; then
  > log/development.log
  > log/production.log

elif [ "$1" = 'logs' ]; then
  if [ -z "$2" ]; then
    tail -20f log/production.log
  else
    tail -20f log/$2.log
  fi
else
  exec "$@"
fi
