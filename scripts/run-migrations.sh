#!/bin/bash

help()
{
  echo "Creates the DB schema for a new installation"
  echo
  echo "Syntax: $0 [-c containerImage] [-e .envFile]"
  echo "  -h  show this help text"
  echo "  -c [container]  Image to run in, e.g. thelocal/coopcycle-web"
  echo "  -e [envFile]  Path to environment file. Defaults to .env"
}

get_abs_filename() {
  # $1 : relative filename
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

cd $(dirname "$0")
SCRIPT_DIR=$(pwd)
DEPLOYMENT_DIR="$SCRIPT_DIR"/..
cd -

CONTAINER_TAG_PREFIX=thelocal
UPLOAD=false

CONTAINER=thelocal/coopcycle-web
ENV_FILE="$DEPLOYMENT_DIR"/.env

while getopts "hc:e:" arg; do
  case $arg in
    h)
      help
      exit
      ;;
    c)
      CONTAINER=$OPTARG
      ;;
    e)
      ENV_FILE=$(get_abs_filename "$OPTARG")
      ;;
  esac
done

set -x

read -r -d '' CMD << EOM
echo \"Running migrations\" \
&& php bin/console doctrine:migrations:migrate \
&& php bin/console doctrine:schema:update --env=prod --force --no-interaction \
&& echo \"Done\"
EOM

echo $ENV_FILE

docker run --rm -it \
  -v "$ENV_FILE":/server/.env \
  "$CONTAINER" \
  /bin/sh -c "$CMD"
