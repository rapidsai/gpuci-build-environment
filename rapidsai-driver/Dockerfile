ARG FROM_IMAGE=gpuci/rapidsai-arm64
ARG RAPIDS_VER=0.15
ARG CUDA_VER=11.2
ARG IMAGE_TYPE=devel
ARG LINUX_VER=ubuntu18.04
ARG PYTHON_VER=3.7
FROM ${FROM_IMAGE}:${RAPIDS_VER}-cuda${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}-py${PYTHON_VER}
# Installs cuda-drivers and cuda libraries for conda builds on CPU-only machines

# Required arguments
ARG DRIVER_VER="440"
ARG LINUX_VER=ubuntu18.04

# Update and add pkgs
RUN if [ $(arch) = "x86_64" ]; then \
    apt-get update -q \
    && apt-get -qq install apt-utils -y --no-install-recommends \
      nvidia-${DRIVER_VER}-dev \
      libcuda1-${DRIVER_VER} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* ; \
  elif [ $(arch) = "aarch64" ]; then \
    wget "http://developer.download.nvidia.com/compute/cuda/repos/${LINUX_VER//./}/sbsa/cuda-${LINUX_VER//./}.pin" -O /etc/apt/preferences.d/cuda-repository-pin-600 \
    && apt-get update -q \
    && apt-get -qq install apt-utils -y --no-install-recommends \
      nvidia-driver-${DRIVER_VER} \
      cuda-drivers-${DRIVER_VER} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* ; \
  else \
    echo "Unsuported arch" \
    && exit 1 ; \
  fi
