#!/bin/bash

# Set environment variables
ENV_NAME=$1
APP_NAME=$2
IMAGE_NAME=$3

# Execute the first yq command
yq_result=$(yq e '.image.tag' ${ENV_NAME}/${APP_NAME}/values.yaml)

# Display the result of the first yq command
echo "Result of the first yq command: ${yq_result}"

# Check if the first yq command succeeded
if [ $? -eq 0 ]; then
    # Execute the second yq command to update the image tag
    yq e ".image.tag = \"${IMAGE_NAME}\"" -i ${ENV_NAME}/${APP_NAME}/values.yaml

    # Display a message indicating the update
    echo "Updated image tag to: ${IMAGE_NAME}"
else
    # Display an error message if the first yq command failed
    echo "Error: Unable to retrieve the current image tag. Exiting."
    exit 1
fi
