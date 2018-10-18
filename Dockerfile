ARG CUDA_VERSION=9.2
ARG LINUX_VERSION=ubuntu16.04
FROM nvidia/cuda:${CUDA_VERSION}-devel-${LINUX_VERSION}

# Define arguments
ARG CC_VERSION=5
ARG CXX_VERSION=5
ARG PYTHON_VERSION=3.5
ARG NUMBA_VERSION=0.40.0
ARG NUMPY_VERSION=1.14.5
ARG PANDAS_VERSION=0.20.3
ARG PYARROW_VERSION=0.10
ARG HASH_JOIN=ON
ARG MINICONDA_URL="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"

# Set environment
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
## Needed for pygdf.concat(), avoids "OSError: library nvvm not found"
ENV NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
ENV NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice/
ENV CC=/usr/bin/gcc-${CC_VERSION}
ENV CXX=/usr/bin/g++-${CXX_VERSION}
ENV PATH=${PATH}:/conda/bin

# Update and add pkgs
RUN apt update -y --fix-missing && \
    apt upgrade -y && \
    apt install -y \
      curl \
      git \
      gcc-${CC_VERSION} \
      g++-${CXX_VERSION} \
      libboost-all-dev \
      wget \
    && rm -rf /var/lib/apt/lists/*

# Install conda
## Build combined libgdf/pygdf conda env
RUN curl ${MINICONDA_URL} -o /miniconda.sh && \
    sh /miniconda.sh -b -p /conda && \
    conda update -n base conda && \
    conda install python=${PYTHON_VERSION} && \
    rm -f /miniconda.sh && \
    conda create -n gdf python=${PYTHON_VERSION} && \
    conda install -n gdf -y -c numba \
      -c conda-forge \
      cmake \
      make \
      numba=${NUMBA_VERSION} \
      numpy=${NUMPY_VERSION} \
      numpy-base=${NUMPY_VERSION} \
      pandas=${PANDAS_VERSION} \
      pyarrow=${PYARROW_VERSION} \
      pytest \
      scikit-learn \
      scipy \
    && conda clean -a && \
    chmod 777 -R /conda

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENV TINI_VERSION=v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
