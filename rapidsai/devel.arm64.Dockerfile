ARG FROM_IMAGE=gpuci/miniforge-cuda
ARG CUDA_VER=11.0
ARG LINUX_VER=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VER}-devel-${LINUX_VER}

# Required arguments
ARG RAPIDS_CHANNEL=rapidsai-nightly
ARG RAPIDS_VER=0.15
ARG PYTHON_VER=3.7

# Optional arguments
ARG BUILD_STACK_VER=9.4.0

# Capture argument used for FROM
ARG CUDA_VER

# Update environment for gcc/g++ builds
ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++
ENV CUDAHOSTCXX=/usr/bin/g++
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib

# Set variable for mambarc
ENV CONDARC=/opt/conda/.condarc

# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Add a condarc for channels and override settings
RUN if [ "${RAPIDS_CHANNEL}" == "rapidsai" ] ; then \
      echo -e "\
auto_update_conda: False \n\
ssl_verify: False \n\
channels: \n\
  - gpuci \n\
  - rapidsai \n\
  - nvidia \n\
  - pytorch \n\
  - conda-forge \n" > /opt/conda/.condarc \
      && cat ${CONDARC} ; \
    else \
      echo -e "\
auto_update_conda: False \n\
ssl_verify: False \n\
channels: \n\
  - gpuci \n\
  - rapidsai-nightly \n\
  - rapidsai \n\
  - nvidia \n\
  - pytorch \n\
  - conda-forge \n" > /opt/conda/.condarc \
      && cat ${CONDARC} ; \
    fi

# Install gcc9
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y ppa:ubuntu-toolchain-r/test \
    && apt-get update \
    && apt-get install -y gcc-9 g++-9 libstdc++6 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9 \
    && update-alternatives --set gcc /usr/bin/gcc-9 \
    && update-alternatives --set g++ /usr/bin/g++-9 \
    && gcc --version \
    && g++ --version

# Update and add pkgs for gpuci builds
RUN apt-get update -y --fix-missing \
    && apt-get -qq install apt-utils -y --no-install-recommends \
    && apt-get install -y \
      chrpath \
      file \
      libnuma1 \
      libnuma-dev \
      libopenmpi-dev \
      openmpi-bin \
      screen \
      tzdata \
      vim \
      zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install latest awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -rf ./aws ./awscliv2.zip

# Add core tools to base env
RUN conda install -y gpuci-tools \
    || conda install -y gpuci-tools

# Create `rapids` conda env and make default
RUN gpuci_conda_retry create --no-default-packages --override-channels -n rapids \
      -c nvidia \
      -c conda-forge \
      -c gpuci \
      anaconda-client \
      codecov \
      cudatoolkit="${CUDA_VER}" \
      git \
      git-lfs \
      gpuci-tools \
      jq \
      libgcc-ng="${BUILD_STACK_VER}" \
      libstdcxx-ng="${BUILD_STACK_VER}" \
      mamba \
      python="${PYTHON_VER}" \
      "python_abi=*=*cp*" \
      rapids-scout-local \
      sccache \
      "setuptools>50" \
    && sed -i 's/conda activate base/conda activate rapids/g' ~/.bashrc

# Install build/doc/notebook env meta-pkgs
#
# Once installed remove the meta-pkg so dependencies can be freely updated &
# the meta-pkg can be installed again with updates
RUN gpuci_conda_retry install -y -n rapids --freeze-installed \
      rapids-build-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER} \
    && gpuci_conda_retry remove -y -n rapids --force-remove \
      rapids-build-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER}

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/tini", "--" ]
CMD [ "/bin/bash" ]
