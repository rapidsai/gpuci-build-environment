#!/bin/bash
set -e

# Overwrite HOME to WORKSPACE
export HOME=$WORKSPACE

# Install gpuCI tools
curl -s https://raw.githubusercontent.com/rapidsai/gpuci-tools/master/install.sh | bash
source ~/.bashrc
cd ~

# Show env
gpuci_logger "Exposing current environment..."
env

# Login to docker
gpuci_logger "Logging into Docker..."
echo $DH_TOKEN | docker login --username $DH_USER --password-stdin

# Get build info ready
gpuci_logger "Preparing to build..."
BUILD_TAG="${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}"
BUILD_ARGS="--squash --build-arg=$FROM_IMAGE --build-arg CUDA_VER=$CUDA_VER --build-arg IMAGE_TYPE=$IMAGE_TYPE --build-arg LINUX_VER=$LINUX_VER"
# Check if PYTHON_VER is set
if [ -z "$PYTHON_VER" ] ; then
  gpuci_logger "PYTHON_VER is not set, skipping..."
else
  gpuci_logger "PYTHON_VER is set to '$PYTHON_VER', adding to build args/tag..."
  BUILD_ARGS="${BUILD_ARGS} --build-arg PYTHON_VER=${PYTHON_VER}"
  BUILD_TAG="${BUILD_TAG}-py${PYTHON_VER}"
fi
# Check if DRIVER_VER is set
if [ -z "$DRIVER_VER" ] ; then
  gpuci_logger "DRIVER_VER is not set, skipping..."
else
  gpuci_logger "DRIVER_VER is set to '$DRIVER_VER', adding to build args..."
  BUILD_ARGS="${BUILD_ARGS} --build-arg DRIVER_VER=${DRIVER_VER}"
fi
gpuci_logger "Build image and tag: ${BUILD_IMAGE}:${BUILD_TAG}"
gpuci_logger "Build args: ${BUILD_ARGS}"

# Build image
gpuci_logger "Starting build..."
docker build --no-cache --pull -t ${BUILD_IMAGE}-new:${BUILD_TAG} ${BUILD_ARGS} -f ${IMAGE_NAME}/${DOCKER_FILE} ${IMAGE_NAME}/

# Upload image
gpuci_logger "Starting upload..."
GPUCI_RETRY_MAX=5
GPUCI_RETRY_SLEEP=120
gpuci_retry docker push ${BUILD_IMAGE}-new:${BUILD_TAG}