#!/bin/bash
set -x
#constants
PATH=$PATH:/usr/local/bin; export PATH
REGION=eu-west-2
REPOSITORY_NAME=direction-app
CLUSTER=direction-app-cluster
FAMILY=direction-task-definition
NAME=direction-task-definition
SERVICE_NAME=direction-app-service
BUILD_NUMBER=11
env
aws configure list
echo $HOME

# store the repositoryUri as a variable
REPOSITORY_URI=`aws ecr describe-repositories --repository-names ${REPOSITORY_NAME} --region ${REGION} | jq -r '.repositories[] |.repositoryUri'`

# store the imageUri as a variable
# IMAGE_URI=319670758662.dkr.ecr.ca-central-1.amazonaws.com/direction-app:2022.0.${BUILD_NUMBER}
IMAGE_URI=$REPOSITORY_URI:2022.3.${BUILD_NUMBER}

# fetch task definition to be updated and store as constant
TASK_DEFINITION=`aws ecs describe-task-definition --task-definition ${FAMILY} --region ${REGION}`

# update task definition with new image URL and store as new_task_definition
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$IMAGE_URI" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')

# register new task definition
aws ecs register-task-definition --region ${REGION} --cli-input-json "$NEW_TASK_DEFINITION"

# set revision as a constant
REVISION=`aws ecs describe-task-definition --task-definition ${FAMILY} --region ${REGION} | jq .taskDefinition.revision`

# fetch service and store as constant
SERVICE=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION} | jq '.services[] |.status'`

# stop ecs_service task # create or update service
if [ "$SERVICE" != "null" ]; then  
  echo "entered existing service"
  DESIRED_COUNT=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION} | jq '.services[] |.desiredCount'`
  RUNNING_TASK=`aws ecs list-tasks --cluster ${CLUSTER} --region ${REGION} | jq -r '.taskArns[0]'`
  echo $RUNNING_TASK
  echo "running task is"
  if [ "$RUNNING_TASK" !=  "null" ];  then
    aws ecs stop-task --cluster ${CLUSTER} --region ${REGION} --task $RUNNING_TASK
  fi
  if [ ${DESIRED_COUNT} = "0" ]; then
    DESIRED_COUNT="1"
  fi
  aws ecs update-service --cluster ${CLUSTER} --region ${REGION} --service ${SERVICE_NAME} --task-definition ${FAMILY}:${REVISION} --desired-count ${DESIRED_COUNT}
else
  echo "entered new service"
  aws ecs create-service --service-name ${SERVICE_NAME} --desired-count 1 --task-definition ${FAMILY} --cluster ${CLUSTER} --region ${REGION}
fi