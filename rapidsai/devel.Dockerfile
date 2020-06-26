ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VER=10.2
ARG LINUX_VER=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VER}-devel-${LINUX_VER}

# Required arguments
ARG RAPIDS_CHANNEL=rapidsai-nightly
ARG RAPIDS_VER=0.15
ARG PYTHON_VER=3.6

# Optional arguments
ARG BUILD_STACK_VER=7.5.0
ARG CCACHE_VERSION=master

# Capture argument used for FROM
ARG CUDA_VER

# Update environment for gcc/g++ builds
ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++
ENV CUDAHOSTCXX=/usr/bin/g++
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib

# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Add a condarc for channels and override settings
RUN if [ "${RAPIDS_CHANNEL}" == "rapidsai" ] ; then \
      echo -e "\
ssl_verify: False \n\
channels: \n\
  - rapidsai \n\
  - conda-forge \n\
  - nvidia \n\
  - defaults \n" > /conda/.condarc \
      && cat /conda/.condarc ; \
    else \
      echo -e "\
ssl_verify: False \n\
channels: \n\
  - rapidsai \n\
  - rapidsai-nightly \n\
  - conda-forge \n\
  - nvidia \n\
  - defaults \n" > /conda/.condarc \
      && cat /conda/.condarc ; \
    fi

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
      jq \
      libnuma1 \
      libnuma-dev \
      screen \
      tzdata \
      vim \
      zlib1g-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install latest awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf ./aws ./awscliv2.zip

# Add core tools to base env
RUN source activate base \
    && conda install -y --override-channels -c gpuci gpuci-tools \
    && gpuci_retry conda install -y \
      anaconda-client \
      codecov

# Create `rapids` conda env and make default
RUN source activate base \
    && gpuci_retry conda create --no-default-packages --override-channels -n rapids \
      -c nvidia \
      -c conda-forge \
      -c defaults \
      nomkl \
      cudatoolkit=${CUDA_VER} \
      git \
      libgcc-ng=${BUILD_STACK_VER} \
      libstdcxx-ng=${BUILD_STACK_VER} \
      python=${PYTHON_VER} \
    && sed -i 's/conda activate base/conda activate rapids/g' ~/.bashrc

# Create symlink for old scripts expecting `gdf` conda env
RUN ln -s /opt/conda/envs/rapids /opt/conda/envs/gdf

# Install build/doc/notebook env meta-pkgs
#
# Once installed remove the meta-pkg so dependencies can be freely updated &
# the meta-pkg can be installed again with updates
RUN gpuci_retry conda install -y -n rapids --freeze-installed \
      rapids-build-env=${RAPIDS_VER} \
      rapids-doc-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER} \
    && conda remove -y -n rapids --force-remove \
      rapids-build-env=${RAPIDS_VER} \
      rapids-doc-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER}

# Build ccache from source and create symlinks
#RUN curl -s -L https://github.com/ccache/ccache/archive/master.zip -o /tmp/ccache-${CCACHE_VERSION}.zip \
#    && unzip -d /tmp/ccache-${CCACHE_VERSION} /tmp/ccache-${CCACHE_VERSION}.zip \
#    && cd /tmp/ccache-${CCACHE_VERSION}/ccache-master \
#    && ./autogen.sh \
#    && ./configure --disable-man --with-libb2-from-internet --with-libzstd-from-internet\
#    && make install -j \
#    && cd / \
#    && rm -rf /tmp/ccache-${CCACHE_VERSION}* \
#    && mkdir -p /ccache

# Setup ccache env vars
#ENV CCACHE_NOHASHDIR=
#ENV CCACHE_DIR="/ccache"
#ENV CCACHE_COMPILERCHECK="%compiler% --version"

# Uncomment these env vars to force ccache to be enabled by default
#ENV CC="/usr/local/bin/gcc"
#ENV CXX="/usr/local/bin/g++"
#ENV NVCC="/usr/local/bin/nvcc"
#ENV CUDAHOSTCXX="/usr/local/bin/g++"
#RUN ln -s "$(which ccache)" "/usr/local/bin/gcc" \
#    && ln -s "$(which ccache)" "/usr/local/bin/g++" \
#    && ln -s "$(which ccache)" "/usr/local/bin/nvcc"

# Clean up pkgs to reduce image size and chmod for all users
RUN conda clean -afy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
