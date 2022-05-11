ARG FROM_IMAGE=gpuci/miniforge-cuda
ARG CUDA_VER=10.2
ARG LINUX_VER=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VER}-runtime-${LINUX_VER} AS base

# Required arguments
ARG IMAGE_TYPE=base
ARG RAPIDS_VER=0.15
ARG PYTHON_VER=3.7

# Capture argument used for FROM
ARG CUDA_VER

# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Add a condarc for channels and override settings
COPY .condarc /opt/conda/.condarc

# Create rapids conda env and make default
RUN conda install -y mamba \
    || conda install -y mamba
RUN wget https://github.com/rapidsai/gpuci-tools/releases/latest/download/tools.tar.gz -O - \
    | tar -xz -C /usr/local/bin
RUN gpuci_conda_retry create --no-default-packages --override-channels -n rapids \
      -c nvidia \
      -c conda-forge \
      -c gpuci \
      cudatoolkit=${CUDA_VER} \
      git \
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

ENTRYPOINT [ "/opt/conda/bin/tini", "--" ]
CMD [ "/bin/bash" ]
