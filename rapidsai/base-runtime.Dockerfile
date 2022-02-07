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
ARG BUILD_STACK_VER=9.4.0

# Capture argument used for FROM
ARG CUDA_VER

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

# Create rapids conda env and make default
RUN conda install -y gpuci-tools mamba \
    || conda install -y gpuci-tools mamba
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
      "setuptools>50" \
    && sed -i 's/conda activate base/conda activate rapids/g' ~/.bashrc

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
RUN chmod -R ugo+w /opt/conda \
    && conda clean -tipy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/tini", "--" ]
CMD [ "/bin/bash" ]
