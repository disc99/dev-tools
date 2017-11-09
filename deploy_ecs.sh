#!/bin/bash

CLUSTER=$1
SERVICE=$2
ECR=$3
TASK_DEFINITION_PATH=$4
BUILD_ID=$5

REPOSITORY=${ECR}/${SERVICE}

# login ECR
login="$(aws ecr get-login --region ap-northeast-1)"
${login}

# for backup
docker tag ${SERVICE} ${REPOSITORY}:${BUILD_ID}
docker push ${REPOSITORY}:${BUILD_ID}

# for deploy
docker tag ${SERVICE} ${REPOSITORY}:latest
docker push ${REPOSITORY}:latest

# update task definition
aws ecs register-task-definition --cli-input-json file://${TASK_DEFINITION_PATH}/${SERVICE}.json --region "ap-northeast-1"

# update service
aws ecs update-service --service ${SERVICE} --task-definition ${SERVICE} --cluster ${CLUSTER} --region "ap-northeast-1"
