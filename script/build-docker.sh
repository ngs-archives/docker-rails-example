#!/bin/sh
set -eu

erb Dockerfile.erb > Dockerfile
docker build -t "${DOCKER_REPO}:${ROLE}" .
