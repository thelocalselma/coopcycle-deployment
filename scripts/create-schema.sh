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

SCRIPT_DIR=$(dirname $(get_abs_filename "$0"))
APP_DIR="$SCRIPT_DIR"/../..
echo $APP_DIR

CONTAINER=thelocal/coopcycle-web
ENV_FILE="$APP_DIR"/.env

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
echo \"Creating Schema\" \
&& php bin/console doctrine:schema:create --env=prod \
&& bin/demo --env=prod \
&& php bin/console doctrine:migrations:version --no-interaction --quiet --add --all \
&& echo \"Done\""
EOM

docker run --rm -it \
  -v "$ENV_FILE":/server/.env \
  "$CONTAINER" \
  /bin/sh -c "$CMD"
