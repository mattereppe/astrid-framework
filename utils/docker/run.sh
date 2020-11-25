#!/bin/bash
# ASTRID
# author: Alex Carrega <alessandro.carrega@cnit.it>

WORK_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage() {
    echo "Usage: $0 <dockerfile-path> <component-version>"
    exit $1
}

if [ -z "$1" ]; then
    echo "Error: missing Dockerfile path"
    usage 1
fi

if [ -z "$2" ]; then
    echo "Error: missing component version"
    usage 2
fi

DOCKERFILE_PATH=$1

source "$DOCKERFILE_PATH/scripts/vars.sh"

VERSION=$2

if [ -z "$DOCKER_TAG" ]; then
    DOCKER_TAG="${PROJECT}project/$COMPONENT:$VERSION"
fi

docker stop $COMPONENT.$VERSION
docker rm $COMPONENT.$VERSION
docker image rm $DOCKER_TAG

if [ ! -z "$CB_MAN_PORT" ]; then
    CB_MAN_PORT_ARG="-p $CB_MAN_PORT:$CB_MAN_PORT"
fi

if [ ! -z "$LCP_PORT" ]; then
    LCP_PORT_ARG="-p $LCP_PORT:$LCP_PORT"
fi

if [ ! -z "$CB_MAN_ELASTICSEARCH_ENDPOINT" ]; then
    CB_MAN_ELASTICSEARCH_ENDPOINT_ENV="-e CB_MAN_ELASTICSEARCH_ENDPOINT=$CB_MAN_ELASTICSEARCH_ENDPOINT"
fi

docker run -d $CB_MAN_ELASTICSEARCH_ENDPOINT_ENV \
            $CB_MAN_PORT_ARG \
            $LCP_PORT_ARG \
        --add-host=host.docker.internal:host-gateway \
        --name $COMPONENT.$VERSION -t $DOCKER_TAG

COMPUTER=$'\xF0\x9F\x92\xBB'
PACKAGE=$'\xF0\x9F\x93\xA6'
SPEAKER=$'\xF0\x9F\x93\xA2'

echo "Send notification via Telegram"
rm -rf "$HOME/log/docker-container-list.png"
docker container list | convert -extent 1000x200 -gravity center label:@- "$HOME/log/docker-container-list.png"
bash "$WORK_PATH/../send2telegram/photo.sh" "$HOME/log/docker-container-list.png" "$COMPUTER azure $PACKAGE $COMPONENT $SPEAKER run"
