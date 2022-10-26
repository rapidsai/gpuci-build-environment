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

# Update environment
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
RUN wget https://github.com/rapidsai/gpuci-tools/releases/latest/download/tools.tar.gz -O - \
    | tar -xz -C /usr/local/bin

RUN gpuci_conda_retry install -y \
      anaconda-client \
      codecov

# Create `rapids` conda env and make default
RUN gpuci_conda_retry create --no-default-packages --override-channels -n rapids \
      -c conda-forge \
      -c nvidia \
      -c gpuci \
      git \
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
