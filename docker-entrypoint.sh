#!/bin/bash -l

# this file is used by docker but can be used
# outside of docker for everything but production

# Builtin commands:
# start [max [heap [min]]] - start rails server
# update - try to update everything to last version keeping current content intact
# reset - clean and prepare a production environment (should only be used with docker)
# reset_log - clear logs
# log [environment=production] - show scrolling log (uses tail -f)
# debug - idle indefinitely and allow access to container with docker exec

#####################
# main functions

function start {
  try_permissions
  if [ ! -f .env ]; then
    echo "Setting up ..."
    reset
  fi
  get_env
  ./railsStart $1 $2 $3
}

function debug {
  echo "Idling indefinitely. Use CTRL+C to stop."
  echo "To debug use: docker exec -i -t genericsparqlendpoint_owwebserver_1 /bin/bash -l"
  while true; do sleep 100; done
  exit
}

function update {
  get_env
  bundle_install
  rake db:migrate assets:precompile
}

function reset {
  set_env
  get_env
  rake db:drop db:create db:migrate assets:precompile assets:clean
  rm -rf db/tdb/*
}

function reset_log {
  > log/production.log
}

function log {
  tail -20f log/production.log
}

#####################
# auxiliary functions

function try_permissions {
  echo "export ONTOWORKSTMP=check" > .ontoworks_tmp
  source .ontoworks_tmp
  rm .ontoworks_tmp
  if [ ! "$ONTOWORKSTMP" = "check" ]; then
    echo "Can't write to rails directory. Entering debug mode ..."
    debug
  fi
}

function set_env {
  echo "export SECRET_KEY_BASE=$(rake secret)" > .env
  echo "export CLASSPATH=/usr/share/java/postgresql-jdbc.jar" >> .env
}

function get_env {
  source .env
}

function bundle_install {
  bundle install
}

#####################
# main script

funcs=":start: :debug: :update: :reset: :reset_log: :log:"
case "$funcs" in
  *":$1:"*) $1 $2 $3 $4
  ;;
  *) exec "$@"
  ;;
esac
