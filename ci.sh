#!/bin/bash

if [ "$TRAVIS_PULL_REQUEST" = "true" ] || [ "$TRAVIS_BRANCH" != "master" ]; then
  docker buildx build \
    --progress plain \
    --platform=linux/arm64,linux/arm/v7,linux/arm/v6 \
    .
  exit $?
fi
echo $DOCKER_PASSWORD | docker login -u dockerpirate --password-stdin &> /dev/null
TAG="v1.10.1-312"
docker buildx build \
     --progress plain \
    --platform=linux/arm64,linux/arm/v7,linux/arm/v6 \
    -t $DOCKER_REPO:$TAG \
    --push \
TAG2="${TRAVIS_TAG:-latest}"
docker buildx build \
     --progress plain \
    --platform=linux/arm64,linux/arm/v7,linux/arm/v6 \
    -t $DOCKER_REPO:$TAG2 \
    --push \
    .