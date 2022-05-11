ARG FROM_IMAGE=gpuci/miniforge-cuda
ARG CUDA_VER=11.2
ARG IMAGE_TYPE=devel
ARG LINUX_VER=centos7
FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}
# Installs cuda-drivers and cuda libraries for conda builds on CPU-only machines
#    and installs build deps for conda builds

# Required arguments
ARG DRIVER_VER="440"

# Add core tools to base env
RUN wget https://github.com/rapidsai/gpuci-tools/releases/latest/download/tools.tar.gz -O - \
    | tar -xz -C /usr/local/bin
RUN source activate base \
    && gpuci_conda_retry install -k -y -c conda-forge \
      anaconda-client \
      codecov \
      conda-build=3.20.4 \
      conda-verify \
      ripgrep \
    && chmod -R ugo+w /opt/conda

# Add NVIDIA repository
RUN yum-config-manager --add-repo http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/cuda-rhel7.repo

RUN yum install -y epel-release

# Install NVIDIA driver
RUN yum install -y epel-release \
    && yum install -y nvidia-driver-branch-${DRIVER_VER}-cuda \
    && yum clean all \
    && rm -rf /var/cache/yum
