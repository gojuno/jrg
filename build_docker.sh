#!/bin/bash
set -e -u -x
export HUB="${HUB:-geocoder.fakehub.net}"
export VERSION="${VERSION:-master}"

PS_IMAGE=${HUB}/geocoder:${VERSION}

WORKDIR="$(cd "$(dirname "$0")"; pwd)"
DOCKER_DIR="$WORKDIR/docker"
mkdir -p "$DOCKER_DIR/input"
cp "$1" "$DOCKER_DIR/input/area_of_interest.osm.pbf"
cp -r "$WORKDIR/sql"/* "$DOCKER_DIR/input/"

# Building the docker container
(
    cd "$DOCKER_DIR"
    docker build -t $PS_IMAGE --build-arg HUB=${HUB} --build-arg VERSION=${VERSION} --no-cache .
)
rm -r "$DOCKER_DIR/input"
