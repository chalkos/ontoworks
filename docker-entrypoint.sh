#!/bin/bash -l
set -e

echo "NOTICE: this is still a test"

if [ "$1" = 'curr' ]; then
  pwd
elif [ "$1" = 'setup_rails' ]; then
  echo "not yet implemented"
else
  exec "$@"
fi
