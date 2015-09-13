#!/bin/sh
set -eu

DATABASE_URL=$(eval "echo \$DATABASE_URL_$(echo $ENV_NAME | awk '{print toupper($0)}')")
APP_NAME='ngs-docker-rails-example-'
TASK_FAMILY="${APP_NAME}${ENV_NAME}"

DATABASE_URL=$DATABASE_URL erb ecs-task-definitions/task-db-migrate.json.erb > .ecs-task-definition.json
TASK_DEFINITION_JSON=$(aws ecs register-task-definition --family $TASK_FAMILY --cli-input-json "file://$(pwd)/.ecs-task-definition.json")
TASK_REVISION=$(echo $TASK_DEFINITION_JSON | jq .taskDefinition.revision)

aws ecs run-task --cluster default --task-definition "${TASK_FAMILY}:${TASK_REVISION}" | jq .
