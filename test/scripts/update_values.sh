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
    echo "Error: Unable to retrieve the current image tag from ${VALUES_FILE}. Exiting."
    exit 1
fi

# Display the result of the first yq command
echo "Current image tag: ${current_image_tag}"

# Execute the second yq command to update the image tag
yq e ".image.tag = \"${IMAGE_NAME}\"" -i "${VALUES_FILE}"

# Check if the second yq update command succeeded
if [ $? -ne 0 ]; then
    echo "Error: Unable to update the image tag in ${VALUES_FILE}. Exiting."
    exit 1
fi

grep "tag" ${VALUES_FILE}

# Display a message indicating the update
echo "Updated image tag to: ${IMAGE_NAME}"
