#!/bin/bash

# Set the environment variables
APP_NAME=$1
IMAGE_NAME=$2
REGION=$3

# Display the values
echo "APP_NAME: ${APP_NAME}"
echo "IMAGE_NAME: ${IMAGE_NAME}"

# Check if the Docker image exists in the registry
IMAGE_EXIST=$(aws ecr describe-images --repository-name "${APP_NAME}" --image-ids imageTag="${IMAGE_NAME}" --region ${REGION})

# Print the image name in the log
echo "Docker Image Name: ${APP_NAME}/${IMAGE_NAME}"

# Check if the image exists
if [ -n "$IMAGE_EXIST" ]; then
  echo "Image ${APP_NAME}/${IMAGE_NAME} exists"
else
  echo "Image ${APP_NAME}/${IMAGE_NAME} does not exist"
  exit 1
fi
