ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VER=10.2
FROM ${FROM_IMAGE}:${CUDA_VER}-devel-centos7

# Required arguments
ARG RAPIDS_CHANNEL=rapidsai-nightly
ARG RAPIDS_VER=0.15
ARG PYTHON_VER=3.7

# Optional arguments
ARG BUILD_STACK_VER=7.5.0
ARG CENTOS7_GCC7_URL=https://gpuci.s3.us-east-2.amazonaws.com/builds/gcc7.tgz

# Capture argument used for FROM
ARG CUDA_VER

# Update environment for gcc/g++ builds
ENV GCC7_DIR=/usr/local/gcc7
ENV CC=${GCC7_DIR}/bin/gcc
ENV CXX=${GCC7_DIR}/bin/g++
ENV CUDAHOSTCXX=${GCC7_DIR}/bin/g++
ENV CUDA_HOME=/usr/local/cuda
ENV LD_LIBRARY_PATH=${GCC7_DIR}/lib64:$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV PATH=${GCC7_DIR}/bin:$PATH

# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Add a condarc for channels and override settings
RUN if [ "${RAPIDS_CHANNEL}" == "rapidsai" ] ; then \
      echo -e "\
ssl_verify: False \n\
channels: \n\
  - gpuci \n\
  - rapidsai \n\
  - conda-forge \n\
  - nvidia \n\
  - defaults \n" > /opt/conda/.condarc \
      && cat /opt/conda/.condarc ; \
    else \
      echo -e "\
ssl_verify: False \n\
channels: \n\
  - gpuci \n\
  - rapidsai \n\
  - rapidsai-nightly \n\
  - conda-forge \n\
  - nvidia \n\
  - defaults \n" > /opt/conda/.condarc \
      && cat /opt/conda/.condarc ; \
    fi

# Update and add pkgs for gpuci builds
RUN yum install -y \
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
RUN source activate base \
    && conda install -y gpuci-tools \
    && gpuci_conda_retry install -y \
      anaconda-client \
      codecov

# Create `rapids` conda env and make default
RUN source activate base \
    && gpuci_conda_retry create --no-default-packages --override-channels -n rapids \
      -c nvidia \
      -c conda-forge \
      -c defaults \
      -c gpuci \
      cudatoolkit=${CUDA_VER} \
      git \
      gpuci-tools \
      libgcc-ng=${BUILD_STACK_VER} \
      libstdcxx-ng=${BUILD_STACK_VER} \
      python=${PYTHON_VER} \
      "setuptools<50" \
    && sed -i 's/conda activate base/conda activate rapids/g' ~/.bashrc \
    && cp /opt/conda/.condarc /opt/conda/evns/rapids/

# Create symlink for old scripts expecting `gdf` conda env
RUN ln -s /opt/conda/envs/rapids /opt/conda/envs/gdf

# Install build/doc/notebook env meta-pkgs
#
# Once installed remove the meta-pkg so dependencies can be freely updated &
# the meta-pkg can be installed again with updates
RUN source activate base \
    && gpuci_conda_retry install -y -n rapids --freeze-installed \
      rapids-build-env=${RAPIDS_VER} \
      rapids-doc-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER} \
    && gpuci_conda_retry remove -y -n rapids --force-remove \
      rapids-build-env=${RAPIDS_VER} \
      rapids-doc-env=${RAPIDS_VER} \
      rapids-notebook-env=${RAPIDS_VER}

# Install gcc7 from prebuilt tarball
RUN gpuci_retry wget --quiet ${CENTOS7_GCC7_URL} -O /gcc7.tgz \
    && tar xzvf /gcc7.tgz \
    && rm -f /gcc7.tgz

# Clean up pkgs to reduce image size and chmod for all users
RUN conda clean -afy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
