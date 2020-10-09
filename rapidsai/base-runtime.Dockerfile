ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VER=10.2
ARG LINUX_VER=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VER}-runtime-${LINUX_VER} AS base

# Required arguments
ARG IMAGE_TYPE=base
ARG RAPIDS_CHANNEL=rapidsai-nightly
ARG RAPIDS_VER=0.15
ARG PYTHON_VER=3.7

# Optional arguments
ARG BUILD_STACK_VER=7.5.0

# Capture argument used for FROM
ARG CUDA_VER

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

# Create rapids conda env and make default
RUN conda install -y gpuci-tools \
    || conda install -y gpuci-tools
RUN gpuci_conda_retry create --no-default-packages --override-channels -n rapids \
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
    && cp /opt/conda/.condarc /opt/conda/envs/rapids/

# Create symlink for old scripts expecting `gdf` conda env
RUN ln -s /opt/conda/envs/rapids /opt/conda/envs/gdf

# For `runtime` images install notebook env meta-pkg
#
# Once installed remove the meta-pkg so dependencies can be freely updated &
# the meta-pkg can be installed again with updates
RUN if [ "${IMAGE_TYPE}" == "runtime" ] ; then \
      gpuci_conda_retry install -y -n rapids --freeze-installed \
        rapids-notebook-env=${RAPIDS_VER} \
      && gpuci_conda_retry remove -y -n rapids --force-remove \
        rapids-notebook-env=${RAPIDS_VER} ; \
    else \
      echo -e "\n\n>>>> SKIPPING: IMAGE_TYPE is not 'runtime'\n\n"; \
    fi

# Clean up pkgs to reduce image size
RUN conda clean -afy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
