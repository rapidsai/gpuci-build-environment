ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VER=10.2
ARG IMAGE_TYPE=devel
ARG LINUX_VER=ubuntu16.04
FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}
# Installs cuda-drivers and cuda libraries for conda builds on CPU-only machines
#    and installs build deps for conda builds

# Required arguments
ARG DRIVER_VER="440"

# Add core tools to base env
RUN source activate base \
    && conda install -y --override-channels -c gpuci gpuci-tools \
    && gpuci_retry conda install -y \
      anaconda-client \
      codecov \
      conda-build \
      conda-verify \
      ripgrep \
    && chmod -R ugo+w /opt/conda

# Update and add pkgs
RUN apt-get update -q \
    && apt-get -qq install apt-utils -y --no-install-recommends \
      nvidia-${DRIVER_VER}-dev \
      libcuda1-${DRIVER_VER} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*