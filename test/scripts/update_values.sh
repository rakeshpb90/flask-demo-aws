#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 ENV_NAME APP IMAGE_NAME"
  exit 1
fi

# Set environment variables
ENV_NAME=$1
APP=$2
IMAGE_NAME=$3
VALUES_FILE="${CODEBUILD_SRC_DIR}/${ENV_NAME}/${APP}/values.yaml"

# Enable automatic exit on error
set -e


echo -e "\nINFO: Setting environment variables..."
echo "INFO: ENV_NAME: ${ENV_NAME}"
echo "INFO: APP: ${APP}"
echo "INFO: IMAGE_NAME: ${IMAGE_NAME}"


echo -e "\nINFO: Executing the first yq command to retrieve the current image tag..."
current_image_tag=$(yq e '.image.tag' "${VALUES_FILE}")


echo "INFO: Current image tag: ${current_image_tag}"


echo -e "\nINFO: Executing the second yq command to update the image tag in the values file..."
yq e ".image.tag = \"${IMAGE_NAME}\"" -i "${VALUES_FILE}"


echo -e "\nINFO: Lines containing 'tag' in ${VALUES_FILE} after update:"
grep -w "tag" "${VALUES_FILE}"

echo -e "\nINFO: Updated image tag to: ${IMAGE_NAME}"
