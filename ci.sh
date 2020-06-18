#!/bin/bash

ALPINE_M=3
ALPINE_P=12
UNBOUND_M=1.10.1

if [ "$TRAVIS_PULL_REQUEST" = "true" ] || [ "$TRAVIS_BRANCH" != "master" ]; then
  docker buildx build \
    --progress plain \
    --platform=linux/arm64,linux/arm/v7,linux/arm/v6,linux/amd64,linux/386 \
    .
  exit $?
fi
echo $DOCKER_PASSWORD | docker login -u dockerpirate --password-stdin &> /dev/null
TAG="$UNBOUND_M"-"$ALPINE_M""$ALPINE_P"
docker buildx build \
     --progress plain \
    --platform=linux/arm64,linux/arm/v7,linux/arm/v6,linux/amd64,linux/386 \
    -t $DOCKER_REPO:$TAG \
    --push .
TAG_2="${TRAVIS_TAG:-latest}"
docker buildx build \
     --progress plain \
    --platform=linux/arm64,linux/arm/v7,linux/arm/v6,linux/amd64,linux/386 \
    -t $DOCKER_REPO:$TAG_2 \
    --push .
