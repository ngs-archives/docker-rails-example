#!/bin/sh
set -eu

CLUSTER=default
UPPER_ENV_NAME=$(echo $ENV_NAME | awk '{print toupper($0)}')
DATABASE_URL=$(eval "echo \$DATABASE_URL_${UPPER_ENV_NAME}")
REDIS_URL=$(eval "echo \$REDIS_URL_${UPPER_ENV_NAME}")
APP_NAME='ngs-docker-rails-example-'
TASK_FAMILY="${APP_NAME}${ENV_NAME}"
SERVICE_NAME="${APP_NAME}service-${ENV_NAME}"

REDIS_URL=$REDIS_URL DATABASE_URL=$DATABASE_URL \
  erb ecs-task-definitions/service.json.erb > .ecs-task-definition.json
TASK_DEFINITION_JSON=$(aws ecs register-task-definition --family $TASK_FAMILY --cli-input-json "file://$(pwd)/.ecs-task-definition.json")
TASK_REVISION=$(echo $TASK_DEFINITION_JSON | jq .taskDefinition.revision)
DESIRED_COUNT=$(aws ecs describe-services --services $SERVICE_NAME | jq '.services[0].desiredCount')

if [ ${DESIRED_COUNT} = "0" ]; then
    DESIRED_COUNT="1"
fi

SERVICE_JSON=$(aws ecs update-service --cluster ${CLUSTER} --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count ${DESIRED_COUNT})
echo $SERVICE_JSON | jq .

TASK_ARN=$(aws ecs list-tasks --cluster ${CLUSTER} --service ${SERVICE_NAME} | jq -r '.taskArns[0]')
TASK_JSON=$(aws ecs stop-task --task ${TASK_ARN})
echo $TASK_JSON | jq .
