#!/bin/bash

# Check if the required number of arguments are provided
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 APP IMAGE_NAME REGION ENV_NAME"
  exit 1
fi

# Set the environment variables
APP=$1
IMAGE_NAME=$2
REGION=$3
ENV_NAME=$4

# Display the values
echo "INFO: Setting environment variables..."
echo "INFO: APP: ${APP}"
echo "INFO: IMAGE_NAME: ${IMAGE_NAME}"
echo "INFO: REGION: ${REGION}"
echo "INFO: ENV_NAME: ${ENV_NAME}"

# Define the path to the values file
VALUES_FILE="${CODEBUILD_SRC_DIR}/${ENV_NAME}/${APP}/values.yaml"

# Check if the values file exists
echo "INFO: Checking if values file exists..."
if [ ! -f "$VALUES_FILE" ]; then
  echo "ERROR: Values file not found: ${VALUES_FILE}"
  exit 1
fi

# Extract the image name from the file
echo "INFO: Extracting image name from the values file..."
IMAGE_OLD_IMAGE=$(awk '/tag:/ {print $2}' "${VALUES_FILE}")

# Check if the image name is found
echo "INFO: Checking if image name is found in the file..."
if [ -z "$IMAGE_OLD_IMAGE" ]; then
  echo "ERROR: Image name not found in the file: ${VALUES_FILE}"
  exit 1
fi

echo "INFO: Docker Image in the values file: ${APP}/${IMAGE_OLD_IMAGE}"

# Check if the user-supplied Docker image exists in the registry
echo "INFO: Checking if the user-supplied Docker image exists in the registry..."
IMAGE_EXIST=$(aws ecr describe-images --repository-name "${APP}" --image-ids imageTag="${IMAGE_NAME}" --region "${REGION}")

echo ${IMAGE_EXIST}
# Validate the response
if [ -z "$IMAGE_EXIST" ] || [ "$(echo "$IMAGE_EXIST" | jq '.imageDetails')" = "null" ]; then
  echo "ERROR: Image ${APP}/${IMAGE_NAME} does not exist in ${REGION} ECR repository"
  exit 1
else
  echo "INFO: Image ${APP}/${IMAGE_NAME} exists in ${REGION} ECR repository"
fi
