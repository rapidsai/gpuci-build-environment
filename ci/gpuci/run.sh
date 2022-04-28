#!/bin/bash
set -e

# Overwrite HOME to WORKSPACE
export HOME="$WORKSPACE"

# Install gpuCI tools
rm -rf .gpuci
git clone https://github.com/rapidsai/gpuci-tools.git .gpuci
chmod +x .gpuci/tools/*
export PATH="$PWD/.gpuci/tools:$PATH"

# Show env
gpuci_logger "Exposing current environment..."
env

# Login to docker
gpuci_logger "Logging into Docker..."
echo $DH_TOKEN | docker login --username $DH_USER --password-stdin &> /dev/null

# Get build info ready
gpuci_logger "Preparing build args and info..."
# Check if CUDA_VER contains a patch version, if so remove it and def FULL_CUDA_VER
if [ `tr -dc '.' <<<"$CUDA_VER" | awk '{ print length }'` -eq 2 ] ; then
  FULL_CUDA_VER=$CUDA_VER
  CUDA_VER=`echo $CUDA_VER  | tr '.' ' ' | awk '{ print $1 "." $2 }'`
  gpuci_logger "Detected patch version in CUDA_VER - Set CUDA_VER='$CUDA_VER' and FULL_CUDA_VER='$FULL_CUDA_VER'"
fi
BUILD_TAG="${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}"
# Check if CUDA 11+, if so include patch version in CUDA_VER for nvidia/cuda & gpuci/cuda FROM images
if [[ "${CUDA_VER:0:2}" == "10" || "${CUDA_VER:0:1}" == "9" ]] ; then
  echo "Detected CUDA 9/10, no need to update CUDA_VER..."
else
  echo "Detected CUDA 11+, checking FROM_IMAGE..."
  if [[ "$FROM_IMAGE" == "gpuci/cuda" || "$FROM_IMAGE" == "nvidia/cuda" ]] ; then
    echo ">> FROM_IMAGE is an external image, need to update CUDA_VER to pull correct external image..."
    CUDA_VER=$FULL_CUDA_VER
    echo ">> CUDA_VER is now set to '$CUDA_VER'..."
  else
    echo ">> FROM_IMAGE not an external image, no need to update CUDA_VER..."
  fi
fi
# Check if PR build and modify BUILD_IMAGE and BUILD_TAG
if [ "$PR_ID" == "BRANCH" ] ; then
  echo "PR_ID is set to 'BRANCH', skipping PR updates"
else
  echo "PR_ID is set to '$PR_ID', updating BUILD_IMAGE..."
  BUILD_REPO=`echo $BUILD_IMAGE | tr '/' ' ' | awk '{ print $2 }'`
  BUILD_IMAGE="gpucitesting/${BUILD_REPO}-pr${PR_ID}"
  # Check if FROM_IMAGE to see if it is a root build
  if [[ "$FROM_IMAGE" == "gpuci/cuda" || "$FROM_IMAGE" == "nvidia/cuda" || "$FROM_IMAGE" == "gpuci/cuda-l4t" ]]; then
    echo ">> No need to update FROM_IMAGE, using external image..."
  else
    echo ">> Need to update FROM_IMAGE to use PR's version for testing..."
    FROM_REPO=`echo $FROM_IMAGE | tr '/' ' ' | awk '{ print $2 }'`
    FROM_IMAGE="gpucitesting/${FROM_REPO}-pr${PR_ID}"
  fi
fi
# Setup initial BUILD_ARGS
BUILD_ARGS="--squash --build-arg FROM_IMAGE=$FROM_IMAGE --build-arg CUDA_VER=$CUDA_VER --build-arg IMAGE_TYPE=$IMAGE_TYPE --build-arg LINUX_VER=$LINUX_VER"
# Check if FULL_CUDA_VER is set
if [ -z "$FULL_CUDA_VER" ] ; then
  echo "FULL_CUDA_VER is not set, skipping..."
else
  echo "FULL_CUDA_VER is set to '$FULL_CUDA_VER', adding to build args..."
  BUILD_ARGS="${BUILD_ARGS} --build-arg FULL_CUDA_VER=${FULL_CUDA_VER}"
fi
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
# Check if ARCH_TYPE is set
if [ -z "$ARCH_TYPE" ] ; then
  echo "ARCH_TYPE is not set, skipping..."
else
  echo "ARCH_TYPE is set to '$ARCH_TYPE', adding to build args..."
  BUILD_ARGS="${BUILD_ARGS} --build-arg ARCH_TYPE=${ARCH_TYPE}"
fi

# Ouput build config
gpuci_logger "Build config info..."
echo "Build image and tag: ${BUILD_IMAGE}:${BUILD_TAG}"
echo "Build args: ${BUILD_ARGS}"
gpuci_logger "Docker build command..."
echo "docker build --pull -t ${BUILD_IMAGE}:${BUILD_TAG} ${BUILD_ARGS} -f ${IMAGE_NAME}/${DOCKER_FILE} ${IMAGE_NAME}/"

# Build image
gpuci_logger "Starting build..."
GPUCI_RETRY_MAX=1
GPUCI_RETRY_SLEEP=120
gpuci_retry docker build --pull -t ${BUILD_IMAGE}:${BUILD_TAG} ${BUILD_ARGS} -f ${IMAGE_NAME}/${DOCKER_FILE} ${IMAGE_NAME}/

# List image info
gpuci_logger "Displaying image info..."
docker images ${BUILD_IMAGE}:${BUILD_TAG}

# Upload image
gpuci_logger "Starting upload..."
GPUCI_RETRY_MAX=5
GPUCI_RETRY_SLEEP=120
gpuci_retry docker push ${BUILD_IMAGE}:${BUILD_TAG}

# Logout of docker
gpuci_logger "Logout of Docker..."
docker logout

# Clean up build
gpuci_logger "Clean up docker builds on system..."
docker system df
docker system prune --volumes -f
docker system df
