#!/bin/sh
set -eu

DATABASE_URL=$(eval "echo \$DATABASE_URL_$(echo $ENV_NAME | awk '{print toupper($0)}')")
APP_NAME='ngs-docker-rails-example-'
TASK_FAMILY="${APP_NAME}${ENV_NAME}"
SERVICE_NAME="${APP_NAME}service-${ENV_NAME}"

DATABASE_URL=$DATABASE_URL erb ecs-task-definitions/service.json.erb > .ecs-task-definition.json
TASK_DEFINITION_JSON=$(aws ecs register-task-definition --family $TASK_FAMILY --cli-input-json "file://$(pwd)/.ecs-task-definition.json")
TASK_REVISION=$(echo $TASK_DEFINITION_JSON | jq .taskDefinition.revision)
DESIRED_COUNT=$(aws ecs describe-services --services $SERVICE_NAME | jq '.services[0].desiredCount')

if [ ${DESIRED_COUNT} = "0" ]; then
    DESIRED_COUNT="1"
fi

SERVICE_JSON=$(aws ecs update-service --cluster default --service ${SERVICE_NAME} --task-definition ${TASK_FAMILY}:${TASK_REVISION} --desired-count ${DESIRED_COUNT})
echo $SERVICE_JSON | jq .
LB_NAME=$(echo $SERVICE_JSON | jq -r '.service.loadBalancers[0].loadBalancerName')
LB_JSON=$(aws elb describe-load-balancers --load-balancer-name "${LB_NAME}")
DNS_NAME=$(echo $LB_JSON | jq -r '.LoadBalancerDescriptions[0].DNSName')

echo $DNS_NAME
