#!/bin/sh

set -e

help()
{
  echo "Performs a full production build of docker images for:"
  echo "* coopcycle PHP web server"
  echo "* tracking/dispatch location server"
  echo
  echo "Along the way it also builds the web application frontend."
  echo "The build process is containerized. The only host system requirements"
  echo "are /bin/sh and docker."
  echo
  echo "Syntax: $0 [-p containerTagPrefix]"
  echo "  -h  show this help text"
  echo "  -p [prefix]  Tag the built containers with the specified prefix,"
  echo "               e.g. -p coopcycle => coopcycle/coopcycle-web"
  echo "  -P  push the built images to the container registry"
}

cd $(dirname "$0")
SCRIPT_DIR=$(pwd)
APP_DIR="$SCRIPT_DIR"/../..
cd -

CONTAINER_TAG_PREFIX=jasonprado
UPLOAD=false
COOPCYCLE_WEB_PATH="$SCRIPT_DIR"/../../coopcycle-web

while getopts "hc:Pp:" arg; do
  case $arg in
    h)
      help
      exit
      ;;
    c)
      COOPCYCLE_WEB_PATH=$OPTARG
      ;;
    p)
      CONTAINER_TAG_PREFIX=$OPTARG
      ;;
    P)
      UPLOAD=true
      ;;
  esac
done

set -x

cd "$COOPCYCLE_WEB_PATH"
docker build . -f ./docker/php/Dockerfile -t "$CONTAINER_TAG_PREFIX/coopcycle-web"
docker build . -f ./docker/locationserver/Dockerfile -t "$CONTAINER_TAG_PREFIX/coopcycle-locationserver"
docker build . -f ./docker/php_worker/Dockerfile -t "$CONTAINER_TAG_PREFIX/coopcycle-web-worker"

if [ "$UPLOAD" = true ]; then
  docker push "$CONTAINER_TAG_PREFIX/coopcycle-web"
  docker push "$CONTAINER_TAG_PREFIX/coopcycle-locationserver"
  docker push "$CONTAINER_TAG_PREFIX/coopcycle-web-worker"
fi
