#!/bin/bash

TAG=1.10.1-312
TAG_2="${TRAVIS_TAG:-latest}"

if [ "$TRAVIS_PULL_REQUEST" = "true" ] || [ "$TRAVIS_BRANCH" != "master" ]; then
  docker buildx build \
    --progress plain \
    --platform=linux/arm64,linux/arm/v7,linux/arm/v6,linux/amd64,linux/386 \
    .
  exit $?
fi
echo $DOCKER_PASSWORD | docker login -u dockerpirate --password-stdin &> /dev/null

docker buildx build \
     --progress plain \
    --platform=linux/arm64,linux/arm/v7,linux/arm/v6,linux/amd64,linux/386 \
    -t $DOCKER_REPO:$TAG \
    --push .

docker buildx build \
     --progress plain \
    --platform=linux/arm64,linux/arm/v7,linux/arm/v6,linux/amd64,linux/386 \
    -t $DOCKER_REPO:$TAG_2 \
    --push .
