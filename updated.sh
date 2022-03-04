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
BUILD_NUMBER=301
env
aws configure list
echo $HOME

#Store the repositoryUri as a variable
# REPOSITORY_URI=`aws ecr describe-repositories --repository-names direction-app --region ca-central-1 | jq '.repositories[] |.repositoryUri'`
IMAGE_URI=319670758662.dkr.ecr.ca-central-1.amazonaws.com/direction-app:0.0.${BUILD_NUMBER}

# Fetch task definition to be updated and store as contants
TASK_DEFINITION=`aws ecs describe-task-definition --task-definition direction-task-definition --region ca-central-1`

# update task definition with new image URL
NEW_TASK_DEFINTIION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$IMAGE_URI" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')

# register new task definition
aws ecs register-task-definition --region "ca-central-1" --cli-input-json "$NEW_TASK_DEFINTIION"

# set revision contannt
REVISION=`aws ecs describe-task-definition --task-definition direction-task-definition --region ca-central-1 | jq .taskDefinition.revision`

# update service
# aws ecs update-service --cluster ${CLUSTER} --region ${REGION} --service ${SERVICE_NAME} --task-definition ${FAMILY}:${REVISION} --desired-count ${DESIRED_COUNT}

SERVICE=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION} | jq '.services[] |.failures'`

# ROLLOUT_STATE=`aws ecs describe-services --services ${SERVICE_NAME} --cluster ${CLUSTER} --region ${REGION} | jq '.services []|.deployments[]|.rolloutState'`
#   if [ ${ROLLOUT_STATE} = "COMPLETED"]; then

# stop ecs service - task
#Create or update service
if [ "$SERVICE" == "" ]; then
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

#Stop ecs service - task
#Create or update service
if [ "$SERVICE" == "" ]; then  
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
