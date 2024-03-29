#!/bin/bash

# Set the environment variables
APP_NAME=$1
IMAGE_NAME=$2
REGION=$3

# Display the values
echo "INFO: APP_NAME: ${APP_NAME}"
echo "INFO: IMAGE_NAME: ${IMAGE_NAME}"
# Print the image name in the log
echo "INFO: Docker Image Name: ${APP_NAME}/${IMAGE_NAME}"


# Extract the image name from the file
IMAGE_NAME=$(awk '/tag:/ {print $2}' values.yaml)

# Check if the image name is found
if [ -n "$IMAGE_NAME" ]; then
  echo "INFO: Image name found: ${IMAGE_NAME}"
else
  echo "ERROR: Image name not found in the file!"
  exit 1
fi

# Check if the Docker image exists in the registry
IMAGE_EXIST=$(aws ecr describe-images --repository-name "${APP_NAME}" --image-ids imageTag="${IMAGE_NAME}" --region ${REGION})

# Check if the image exists
if [ -n "$IMAGE_EXIST" ]; then
  echo "INFO: Image ${APP_NAME}/${IMAGE_NAME} exists"
else
  echo "ERROR: Image ${APP_NAME}/${IMAGE_NAME} does not exist"
  exit 1
fi
