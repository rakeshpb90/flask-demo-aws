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


# Extract the tag version
TAG_VERSION=$(grep "image:" values.yaml | grep "tag:" | awk '{print $2}')

# Check if the tag version is found
if [ -n "$TAG_VERSION" ]; then
  echo "INFO: Tag version found: ${TAG_VERSION}"
else
  echo "ERROR: Tag version not found in the file!"
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
