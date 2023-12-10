#!/bin/bash

# Set environment variables
ENV_NAME=$1
APP_NAME=$2
IMAGE_NAME=$3
VALUES_FILE="${CODEBUILD_SRC_DIR}/${ENV_NAME}/${APP_NAME}/values.yaml"

# Execute the first yq command to retrieve the current image tag
current_image_tag=$(yq e '.image.tag' "${VALUES_FILE}")

# Check if the first yq command succeeded
if [ $? -ne 0 ]; then
    echo "ERROR: Unable to retrieve the current image tag from ${VALUES_FILE}. Exiting."
    exit 1
fi

# Display the result of the first yq command
echo "INFO: Current image tag: ${current_image_tag}"

# Execute the second yq command to update the image tag in values file
yq e ".image.tag = \"${IMAGE_NAME}\"" -i "${VALUES_FILE}"

# Check if the yq update command succeeded
if [ $? -ne 0 ]; then
    echo "ERROR: Unable to update the image tag in ${VALUES_FILE}. Exiting."
    exit 1
fi

# Display lines containing 'tag' in ${VALUES_FILE} after the update
echo "INFO: Lines containing 'tag' in ${VALUES_FILE} after update:"
grep -w "tag" ${VALUES_FILE}

# Display a message indicating the update
echo "INFO: Updated image tag to: ${IMAGE_NAME}"
