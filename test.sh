# Extract the image name from the file
IMAGE_NAME=$(awk '/tag:/ {print $2}' values.yaml)

# Check if the image name is found
if [ -n "$IMAGE_NAME" ]; then
  echo "INFO: Image name found: ${IMAGE_NAME}"
else
  echo "ERROR: Image name not found in the file!"
  exit 1
fi
