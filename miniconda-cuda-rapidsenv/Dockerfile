ARG CUDA_VERSION=9.2
ARG CUDA_VER=${CUDA_VERSION}
ARG CUDA_TYPE=devel
ARG LINUX_VERSION=ubuntu16.04
ARG PYTHON_VERSION=3.6
FROM gpuci/miniconda-cuda:${CUDA_VERSION}-${CUDA_TYPE}-${LINUX_VERSION}

# Define arguments
ARG CUDA_VER
ARG PYTHON_VERSION
ARG CC_VERSION=5
ARG CXX_VERSION=5
ARG LIB_NG_VERSION=7.3.0

# Set environment
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
## Needed for pygdf.concat(), avoids "OSError: library nvvm not found"
ENV NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
ENV NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice/
ENV CC=/usr/bin/gcc-${CC_VERSION}
ENV CXX=/usr/bin/g++-${CXX_VERSION}
ENV CUDAHOSTCXX=/usr/bin/g++-${CXX_VERSION}
ENV PATH=${PATH}:/conda/bin
ENV DEBIAN_FRONTEND=noninteractive

# Update and add pkgs
RUN apt-get install -y \
      curl \
      git \
      screen \
      gcc-${CC_VERSION} \
      g++-${CXX_VERSION} \
      libboost-all-dev \
      tzdata \
      wget \
      vim \
      zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Create rapids conda env
RUN source activate base \
    && conda create --no-default-packages --override-channels -n rapids \
      -c numba \
      -c conda-forge \
      -c anaconda \
      nomkl \
      anaconda::cudatoolkit=${CUDA_VER} \
      conda-forge::blas=1.1=openblas \
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
