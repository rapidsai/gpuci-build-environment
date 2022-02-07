ARG FROM_IMAGE=gpuci/miniforge-cuda
ARG CUDA_VER=11.0
ARG IMAGE_TYPE=devel
ARG LINUX_VER=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}
# Installs cuda-drivers and cuda libraries for conda builds on CPU-only machines
#    and installs build deps for conda builds

# Required arguments
ARG DRIVER_VER="450"
ARG LINUX_VER

# Add core tools to base env
RUN conda install -k -y --override-channels -c gpuci gpuci-tools \
    && gpuci_conda_retry install -k -y -c conda-forge \
      anaconda-client \
      codecov \
      conda-build=3.19.2 \
      conda-verify \
      ripgrep \
    && chmod -R ugo+w /opt/conda

# Update and add pkgs
RUN if [ $(arch) = "x86_64" ]; then \
    apt-get update -q \
    && apt-get -qq install apt-utils -y --no-install-recommends \
      nvidia-driver-${DRIVER_VER} \
      cuda-drivers-${DRIVER_VER} \
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
