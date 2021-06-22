ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VER=11.0
ARG IMAGE_TYPE=devel
ARG LINUX_VER=centos7
FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}
# Installs cuda-drivers and cuda libraries for conda builds on CPU-only machines
#    and installs build deps for conda builds

# Required arguments
ARG DRIVER_VER="450"

# Add core tools to base env
RUN source activate base \
    && conda install -k -y --override-channels -c gpuci gpuci-tools \
    && gpuci_conda_retry install -k -y -c conda-forge \
      anaconda-client \
      codecov \
      conda-build=3.19.2 \
      conda-verify \
      ripgrep \
    && chmod -R ugo+w /opt/conda

# Add NVIDIA repository
RUN yum-config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo

# Install NVIDIA driver
RUN yum install -y epel-release \
    && yum install -y nvidia-driver-branch-${DRIVER_VER}-cuda \
    && yum clean all \
    && rm -rf /var/cache/yum
