#!/bin/sh
set -eu

DATABASE_URL=$(eval "echo \$DATABASE_URL_$(echo $ENV_NAME | awk '{print toupper($0)}')")

DATABASE_URL=$DATABASE_URL ROLE=web ./script/build-docker.sh
DATABASE_URL=$DATABASE_URL ROLE=job ./script/build-docker.sh
docker tag "${DOCKER_REPO}:web" "${DOCKER_REPO}:web-$ENV_NAME"
docker tag "${DOCKER_REPO}:job" "${DOCKER_REPO}:job-$ENV_NAME"
docker push "${DOCKER_REPO}:web-$ENV_NAME"
docker push "${DOCKER_REPO}:job-$ENV_NAME"

erb ecs-task-definition.json.erb > .ecs-task-definition.json
