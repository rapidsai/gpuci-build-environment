#!/bin/bash
set -e

# Overwrite HOME to WORKSPACE
export HOME=$WORKSPACE

# Install gpuCI tools
curl -s https://raw.githubusercontent.com/rapidsai/gpuci-tools/main/install.sh | bash
source ~/.bashrc
cd ~

# Show env
gpuci_logger "Exposing current environment..."
env

# Login to docker
gpuci_logger "Logging into Docker..."
echo $DH_TOKEN | docker login --username $DH_USER --password-stdin &> /dev/null

# Get build info ready
gpuci_logger "Preparing build args and info..."
BUILD_TAG="${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}"
# Check if PR build and modify BUILD_IMAGE and BUILD_TAG
if [ ! -z "$PR_ID" ] ; then
  echo "PR_ID is set to '$PR_ID', updating BUILD_IMAGE..."
  BUILD_REPO=`echo $BUILD_IMAGE | tr '/' ' ' | awk '{ print $2 }'`
  BUILD_IMAGE="gpucitesting/${BUILD_REPO}-pr${PR_ID}"
  # Check if FROM_IMAGE to see if it is a root build
  if [ "$FROM_IMAGE" == "gpuci/cuda" -o "$FROM_IMAGE" == "nvidia/cuda" ] ; then
    echo ">> No need to update FROM_IMAGE, using external image..."
  else
    echo ">> Need to update FROM_IMAGE to use PR's version for testing..."
    FROM_REPO=`echo $FROM_IMAGE | tr '/' ' ' | awk '{ print $2 }'`
    FROM_IMAGE="gpucitesting/${FROM_REPO}-pr${PR_ID}"
  fi
fi
# Setup initial BUILD_ARGS
BUILD_ARGS="--squash --build-arg FROM_IMAGE=$FROM_IMAGE --build-arg CUDA_VER=$CUDA_VER --build-arg IMAGE_TYPE=$IMAGE_TYPE --build-arg LINUX_VER=$LINUX_VER"
# Check if PYTHON_VER is set
if [ -z "$PYTHON_VER" ] ; then
  echo "PYTHON_VER is not set, skipping..."
else
  echo "PYTHON_VER is set to '$PYTHON_VER', adding to build args/tag..."
  BUILD_ARGS="${BUILD_ARGS} --build-arg PYTHON_VER=${PYTHON_VER}"
  BUILD_TAG="${BUILD_TAG}-py${PYTHON_VER}"
fi
# Check if DRIVER_VER is set
if [ -z "$DRIVER_VER" ] ; then
  echo "DRIVER_VER is not set, skipping..."
else
  echo "DRIVER_VER is set to '$DRIVER_VER', adding to build args..."
  BUILD_ARGS="${BUILD_ARGS} --build-arg DRIVER_VER=${DRIVER_VER}"
fi
# Check if RAPIDS_VER is set
if [ -z "$RAPIDS_VER" ] ; then
  echo "RAPIDS_VER is not set, skipping..."
else
  echo "RAPIDS_VER is set to '$RAPIDS_VER', adding to build args..."
  BUILD_ARGS="${BUILD_ARGS} --build-arg RAPIDS_VER=${RAPIDS_VER}"
  BUILD_TAG="${RAPIDS_VER}-cuda${BUILD_TAG}" #pre-prend version number
fi
# Check if RAPIDS_CHANNEL is set
if [ -z "$RAPIDS_CHANNEL" ] ; then
  echo "RAPIDS_CHANNEL is not set, skipping..."
else
  echo "RAPIDS_CHANNEL is set to '$RAPIDS_CHANNEL', adding to build args..."
  BUILD_ARGS="${BUILD_ARGS} --build-arg RAPIDS_CHANNEL=${RAPIDS_CHANNEL}"
fi

# Ouput build config
gpuci_logger "Build config info..."
echo "Build image and tag: ${BUILD_IMAGE}:${BUILD_TAG}"
echo "Build args: ${BUILD_ARGS}"
gpuci_logger "Docker build command..."
echo "docker build --pull -t ${BUILD_IMAGE}:${BUILD_TAG} ${BUILD_ARGS} -f ${IMAGE_NAME}/${DOCKER_FILE} ${IMAGE_NAME}/"

# Build image
gpuci_logger "Starting build..."
docker build --pull -t ${BUILD_IMAGE}:${BUILD_TAG} ${BUILD_ARGS} -f ${IMAGE_NAME}/${DOCKER_FILE} ${IMAGE_NAME}/

# List image info
gpuci_logger "Displaying image info..."
docker images ${BUILD_IMAGE}:${BUILD_TAG}

# Upload image
gpuci_logger "Starting upload..."
GPUCI_RETRY_MAX=5
GPUCI_RETRY_SLEEP=120
gpuci_retry docker push ${BUILD_IMAGE}:${BUILD_TAG}
