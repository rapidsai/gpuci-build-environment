ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VER=11.0
ARG LINUX_VER=centos7
FROM ${FROM_IMAGE}:${CUDA_VER}-devel-${LINUX_VER}

# Required arguments
ARG RAPIDS_CHANNEL=rapidsai-nightly
ARG RAPIDS_VER=0.15
ARG PYTHON_VER=3.7

# Optional arguments
ARG BUILD_STACK_VER=9.3.0
ARG GCC9_URL=https://gpuci.s3.us-east-2.amazonaws.com/builds/gcc9.tgz

# Capture argument used for FROM
ARG CUDA_VER

# Update environment for gcc/g++ builds
ENV GCC9_DIR=/usr/local/gcc9
ENV CC=${GCC9_DIR}/bin/gcc
ENV CXX=${GCC9_DIR}/bin/g++
ENV CUDAHOSTCXX=${GCC9_DIR}/bin/g++
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=${GCC9_DIR}/lib64:$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV PATH=${GCC9_DIR}/bin:$PATH

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
      && cat /opt/conda/.condarc ; \
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
      && cat /opt/conda/.condarc ; \
    fi

# Update and add pkgs for gpuci builds
RUN yum install -y epel-release \
    && yum install -y --setopt=install_weak_deps=False \
      chrpath \
      clang \
      numactl-devel \
      numactl-libs \
      screen \
      vim \
    && yum clean all

ARG JQPATH=/usr/local/bin/jq
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -O ${JQPATH} \
    && chmod +x $JQPATH

# Install latest awscli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip -q awscliv2.zip \
    && ./aws/install \
    && rm -rf ./aws ./awscliv2.zip

# Add core tools to base env
RUN conda install -y gpuci-tools \
    || conda install -y gpuci-tools
RUN gpuci_conda_retry install -y \
      anaconda-client \
      codecov \
      rapids-scout-local

# Create `rapids` conda env and make default
RUN gpuci_conda_retry create --no-default-packages --override-channels -n rapids \
      -c nvidia \
      -c conda-forge \
      -c gpuci \
      cudatoolkit=${CUDA_VER} \
      git \
      gpuci-tools \
      libgcc-ng=${BUILD_STACK_VER} \
      libstdcxx-ng=${BUILD_STACK_VER} \
      python=${PYTHON_VER} \
      'python_abi=*=*cp*' \
      "setuptools<50" \
    && sed -i 's/conda activate base/conda activate rapids/g' ~/.bashrc

# Install build/doc/notebook env meta-pkgs
#
# Once installed remove the meta-pkg so dependencies can be freely updated &
# the meta-pkg can be installed again with updates
RUN gpuci_conda_retry install -y -n rapids --freeze-installed \
      rapids-build-env=${RAPIDS_VER} \
      rapids-doc-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER} \
    && gpuci_conda_retry remove -y -n rapids --force-remove \
      rapids-build-env=${RAPIDS_VER} \
      rapids-doc-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER}

# Install gcc9 from prebuilt tarball
RUN gpuci_retry wget --quiet ${GCC9_URL} -O /gcc9.tgz \
    && tar xzvf /gcc9.tgz \
    && rm -f /gcc9.tgz

# Clean up pkgs to reduce image size and chmod for all users
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

# Add GDS header cufile.h to image
COPY cufile.h /usr/local/cuda/targets/x86_64-linux/lib/cufile.h

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
