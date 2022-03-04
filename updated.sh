#!/bin/bash
set -x
#Constants
PATH=$PATH:/usr/local/bin; export PATH
REGION=ca-central-1
REPOSITORY_NAME=direction-app
CLUSTER=direction-app-cluster
FAMILY=direction-task-definition
NAME=direction-task-definition
SERVICE_NAME=direction-app-service
env
aws configure list
echo $HOME

#Store the repositoryUri as a variable
REPOSITORY_URI=`aws ecr describe-repositories --repository-names direction-app --region ca-central-1 | jq '.repositories[] |.repositoryUri'`

# Fetch task definition to be updated and store as contants
TASK_DEFINITION=`aws ecs describe-task-definition --task-definition direction-task-definition --region ca-central-1`

# update task definition with new image URL
NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$REPOSITORY_URI" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')

# register new task definition
aws ecs register-task-definition --region "ca-central-1" --cli-input-json "$NEW_TASK_DEFINTIION"

# set revision contannt
REVISION=`aws ecs describe-task-definition --task-definition direction-task-definition --region ca-central-1 | jq .taskDefinition.revision`

# update service
# aws ecs update-service --cluster ${CLUSTER} --region ${REGION} --service ${SERVICE_NAME} --task-definition ${FAMILY}:${REVISION} --desired-count ${DESIRED_COUNT}

#Create or update service
if [ "$SERVICES" == "" ]; then
  echo "entered existing service"
  DESIRED_COUNT=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION} | jq '.services[] |.desiredCount'`
  if [ ${DESIRED_COUNT} = "0" ]; then
    DESIRED_COUNT="1"
  fi
  aws ecs update-service --cluster ${CLUSTER} --region ${REGION} --service ${SERVICE_NAME} --task-definition ${FAMILY}:${REVISION} --desired-count ${DESIRED_COUNT}
else
  echo "entered new service"
  aws ecs create-service --service-name ${SERVICE_NAME} --desired-count 1 --task-definition ${FAMILY} --cluster ${CLUSTER} --region ${REGION}
fi
