ARG FROM_IMAGE=gpuci/rapidsai
ARG CUDA_VER=10.2
ARG IMAGE_TYPE=devel
ARG LINUX_VER=ubuntu18.04
ARG PYTHON_VER=3.6
FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}-py${PYTHON_VER}
# Installs cuda-drivers and cuda libraries for conda builds on CPU-only machines

# Required arguments
ARG DRIVER_VER="396.44-1"

# Update and add pkgs
RUN LIBCUDA_VER=`echo "$DRIVER_VER" | cut -d'.' -f 1` \
    && apt-get update -q \
    && apt-get -qq install apt-utils -y --no-install-recommends \
      cuda-drivers=${DRIVER_VER} \
      libcuda1-${LIBCUDA_VER} \
    && rm -rf /var/lib/apt/lists/*