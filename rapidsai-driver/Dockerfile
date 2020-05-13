ARG FROM_IMAGE=gpuci/rapidsai
ARG CUDA_VER=10.2
ARG IMAGE_TYPE=devel
ARG LINUX_VER=ubuntu18.04
ARG PYTHON_VER=3.6
FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}-py${PYTHON_VER}
# Installs cuda-drivers and cuda libraries for conda builds on CPU-only machines

# Required arguments
ARG DRIVER_VER="440.33.01-0ubuntu1"

# Update and add pkgs
RUN DRIVER_MAJOR_VER=`echo "$DRIVER_VER" | cut -d'.' -f 1` \
    && apt-get update -q \
    && apt-get -qq install apt-utils -y --no-install-recommends \
      nvidia-headless-${DRIVER_MAJOR_VER}=${DRIVER_VER} \
      libnvidia-compute-${DRIVER_MAJOR_VER}=${DRIVER_VER} \
    && rm -rf /var/lib/apt/lists/*