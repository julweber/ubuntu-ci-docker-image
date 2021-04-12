#!/bin/bash

DOCKER_REPO=julianweberdev
IMAGE=ubuntu-ci
TAG=latest
docker run -i -t "$DOCKER_REPO/$IMAGE:$TAG" /bin/bash