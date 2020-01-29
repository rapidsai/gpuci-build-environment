ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VERSION=9.2
ARG CUDA_VER=${CUDA_VERSION}
ARG CUDA_TYPE=devel
ARG LINUX_VERSION=ubuntu16.04
ARG PYTHON_VERSION=3.6
FROM ${FROM_IMAGE}:${CUDA_VERSION}-${CUDA_TYPE}-${LINUX_VERSION}

# Define arguments
ARG CUDA_VER
ARG PYTHON_VERSION
ARG LIB_NG_VERSION=7.3.0

# Set environment
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV PATH=${PATH}:/conda/bin

# Add a condarc for override settings
ADD .condarc /conda/.condarc

# Create rapids conda env
RUN source activate base \
    && conda create --no-default-packages --override-channels -n rapids \
      -c nvidia \
      -c conda-forge \
      -c defaults \
      nomkl \
      cudatoolkit=${CUDA_VER} \
      conda-forge::blas=2.14=openblas \
      libgcc-ng=${LIB_NG_VERSION} \
      libstdcxx-ng=${LIB_NG_VERSION} \
      python=${PYTHON_VERSION} \
    && conda clean -afy \
    && sed -i 's/conda activate base/conda activate rapids/g' ~/.bashrc \
    && chmod -R ugo+w /opt/conda

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
