#!/bin/bash

set -euo pipefail

# Configuration (adjust as needed)
export DOCKER_REPO=julianweberdev/ubuntu-ci

export TAG="latest"

# Build image
docker build -t ${DOCKER_REPO}:${TAG} .

docker tag ${DOCKER_REPO}:${TAG} ${DOCKER_REPO}:latest

# Push image
docker push ${DOCKER_REPO}:${TAG}

# uncomment this if you want to push to latest
# docker push ${DOCKER_REPO}:latest
