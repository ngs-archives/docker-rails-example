#!/bin/sh
set -eu

ROLE=$ROLE ./bin/rake dockerfile:build
docker build -t "${DOCKER_REPO}:${ROLE}" .
