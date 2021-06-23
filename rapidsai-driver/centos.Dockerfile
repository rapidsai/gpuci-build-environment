ARG FROM_IMAGE=gpuci/rapidsai
ARG RAPIDS_VER=0.20
ARG CUDA_VER=11.0
ARG IMAGE_TYPE=devel
ARG LINUX_VER=centos7
ARG PYTHON_VER=3.7
FROM ${FROM_IMAGE}:${RAPIDS_VER}-cuda${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}-py${PYTHON_VER}
# Installs cuda-drivers and cuda libraries for conda builds on CPU-only machines

# Required arguments
ARG DRIVER_VER="440"

# Add NVIDIA repository
RUN yum-config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo

# Install NVIDIA driver
RUN yum install -y epel-release \
    && yum install -y nvidia-driver-branch-${DRIVER_VER}-cuda \
    && yum clean all \
    && rm -rf /var/cache/yum
