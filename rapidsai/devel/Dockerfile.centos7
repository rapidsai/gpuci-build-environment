ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VER=10.2
FROM ${FROM_IMAGE}:${CUDA_VER}-devel-centos7

# Required arguments
ARG RAPIDS_CHANNEL=rapidsai-nightly
ARG RAPIDS_VER=0.14
ARG PYTHON_VER=3.6

# Optional arguments
ARG BUILD_STACK_VER=7.3.0
ARG CENTOS7_GCC7_URL=https://gpuci.s3.us-east-2.amazonaws.com/builds/gcc7.tgz

# Capture argument used for FROM
ARG CUDA_VER

# Update environment for gcc/g++ builds
ENV GCC7_DIR=/usr/local/gcc7
ENV CC=${GCC7_DIR}/bin/gcc
ENV CXX=${GCC7_DIR}/bin/g++
ENV CUDAHOSTCXX=${GCC7_DIR}/bin/g++
ENV LD_LIBRARY_PATH=${GCC7_DIR}/lib64:$CONDA_PREFIX:$LD_LIBRARY_PATH
ENV PATH=${GCC7_DIR}/bin:$PATH

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

# Create `rapids` conda env and make default
RUN source activate base \
    && conda install -y --override-channels -c gpuc gpuci-tools \
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

# Clean up pkgs to reduce image size
RUN conda clean -afy \
    && chmod -R ugo+w /opt/conda

# Install gcc7 from prebuilt tarball
RUN gpuci_retry wget --quiet ${CENTOS7_GCC7_URL} -O /gcc7.tgz \
    && tar xzvf /gcc7.tgz \
    && rm -f /gcc7.tgz

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
