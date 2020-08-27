ARG FROM_IMAGE=gpuci/rapidsai
ARG RAPIDS_VER=0.15
ARG CUDA_VER=10.2
ARG IMAGE_TYPE=devel
ARG LINUX_VER=ubuntu16.04
ARG PYTHON_VER=3.7
FROM ${FROM_IMAGE}:${RAPIDS_VER}-cuda${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}-py${PYTHON_VER}
# Installs cuda-drivers and cuda libraries for conda builds on CPU-only machines

# Required arguments
ARG DRIVER_VER="440"

# Update and add pkgs
RUN apt-get update -q \
    && apt-get -qq install apt-utils -y --no-install-recommends \
      nvidia-${DRIVER_VER}-dev \
      libcuda1-${DRIVER_VER} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*