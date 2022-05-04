ARG FROM_IMAGE=gpuci-miniforge-l4t
ARG CUDA_VER=10.2
ARG LINUX_VER=ubuntu18.04
ARG IMAGE_TYPE=devel
FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}

# Required arguments
ARG RAPIDS_VER=0.15
ARG PYTHON_VER=3.7

# Capture argument used for FROM
ARG CUDA_VER

# Update environment for gcc/g++ builds
ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++
ENV CUDAHOSTCXX=/usr/bin/g++
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV NVCC=/usr/local/cuda/bin/nvcc
ENV CUDAToolkit_ROOT=/usr/local/cuda
ENV CUDACXX=/usr/local/cuda/bin/nvcc

# Add sccache variables
ENV CMAKE_CUDA_COMPILER_LAUNCHER=sccache
ENV CMAKE_CXX_COMPILER_LAUNCHER=sccache
ENV CMAKE_C_COMPILER_LAUNCHER=sccache

# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Add a condarc for channels and override settings
COPY .condarc /opt/conda/.condarc

# Install gcc7 - 7.5.0 to bring build stack in line with conda-forge
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y gcc-7 g++-7 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 7 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 7 \
    && update-alternatives --set gcc /usr/bin/gcc-7 \
    && update-alternatives --set g++ /usr/bin/g++-7 \
    && gcc --version \
    && g++ --version

# Update and add pkgs for gpuci builds
RUN apt-get update -y --fix-missing \
    && apt-get -qq install apt-utils -y --no-install-recommends \
    && apt-get install -y \
      chrpath \
      libnuma1 \
      libnuma-dev \
      screen \
      tzdata \
      vim \
      zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install latest jq
ARG JQPATH=/usr/local/bin/jq
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O ${JQPATH} \
    && chmod +x $JQPATH

# Install latest awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -rf ./aws ./awscliv2.zip

# Add core tools to base env
RUN conda install -y gpuci-tools \
    || conda install -y gpuci-tools

RUN gpuci_conda_retry install -y \
      anaconda-client \
      codecov
# FIXME: Install rapids-scout-local
#      rapids-scout-local

# Create `rapids` conda env and make default
RUN gpuci_conda_retry create --no-default-packages --override-channels -n rapids \
      -c nvidia \
      -c conda-forge \
      -c gpuci \
      git \
      gpuci-tools \
      python=${PYTHON_VER} \
      'python_abi=*=*cp*' \
      "setuptools>50" \
    && sed -i 's/conda activate base/conda activate rapids/g' ~/.bashrc

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/opt/conda/bin/tini", "--" ]
CMD [ "/bin/bash" ]
