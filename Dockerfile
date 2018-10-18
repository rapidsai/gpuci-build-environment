ARG CUDA_VERSION=9.2
ARG LINUX_VERSION=ubuntu16.04
FROM nvidia/cuda:${CUDA_VERSION}-devel-${LINUX_VERSION}
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
# Needed for pygdf.concat(), avoids "OSError: library nvvm not found"
ENV NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
ENV NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice/

# Define arguments
ARG CC_VERSION=5
ARG CXX_VERSION=5
ARG PYTHON_VERSION=3.5
ARG NUMBA_VERSION=0.40.0
ARG NUMPY_VERSION=1.14.5
ARG PANDAS_VERSION=0.23.4
ARG PYARROW_VERSION=0.10
ARG HASH_JOIN=ON
ARG MINICONDA_URL="https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh"

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
ADD https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh /miniconda.sh
RUN sh /miniconda.sh -b -p /conda && /conda/bin/conda update -n base conda
ENV PATH=${PATH}:/conda/bin
# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Build combined libgdf/pygdf conda env
RUN conda create -n gdf python=${PYTHON_VERSION}
RUN conda install -n gdf -y -c numba -c conda-forge -c defaults \
      numba \
      pandas

ENV CC=/usr/bin/gcc-${CC_VERSION}
ENV CXX=/usr/bin/g++-${CXX_VERSION}

# Enable all users to write to system library, to allow for installs
RUN chmod 777 /usr/local/lib /usr/local/include

ENV TINI_VERSION=v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
