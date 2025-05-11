#!/bin/bash
echo "Starting up and deploying latest UAT image..."

gcloud auth configure-docker "${REGION}-docker.pkg.dev" --quiet

docker pull "${IMAGE_NAME}:uat-latest"

CONTAINER_NAME="ananya-hospital-uat"
if docker ps -aq --filter "name=${CONTAINER_NAME}" | grep -q .; then
  echo "Stopping and removing existing container: ${CONTAINER_NAME}"
  docker stop "${CONTAINER_NAME}"
  docker rm "${CONTAINER_NAME}"
fi

# Run the new container
echo "Running the new container: ${CONTAINER_NAME}"
docker run --name "${CONTAINER_NAME}" -d -p 443:443 80:80 "${IMAGE_NAME}:uat-latest"

echo "UAT deployment complete."