ARG CUDA_VERSION=9.2
ARG CUDA_SHORT_VERSION=${CUDA_VERSION}
ARG LINUX_VERSION=ubuntu16.04
FROM nvidia/cuda:${CUDA_VERSION}-devel-${LINUX_VERSION}

# Define arguments
ARG CUDA_SHORT_VERSION
ARG CC_VERSION=5
ARG CXX_VERSION=5
ARG PYTHON_VERSION=3.6
ARG CFFI_VERSION=1.11.5
ARG CYTHON_VERSION=0.29
ARG CMAKE_VERSION=3.12
ARG NUMBA_VERSION=0.45.1
ARG NUMPY_VERSION=1.16.4
ARG PANDAS_VERSION=0.24.2
ARG PYARROW_VERSION=0.14.1
ARG ARROW_CPP_VERSION=0.14.1
ARG DOUBLE_CONVERSION_VERSION=3.1.5
ARG RAPIDJSON_VERSION=1.1.0
ARG FLATBUFFERS_VERSION=1.10.0
ARG BOOST_CPP_VERSION=1.70.0
ARG FASTAVRO_VERSION=0.22.3
ARG DLPACK_VERSION=0.2
ARG SKLEARN_VERSION=0.20.3
ARG SCIPY_VERSION=1.2.1
ARG LIBGCC_NG_VERSION=7.3.0
ARG LIBGFORTRAN_NG_VERSION=7.3.0
ARG LIBSTDCXX_NG_VERSION=7.3.0
ARG TINI_VERSION=v0.18.0
ARG HASH_JOIN=ON
ARG CONDA_VERSION=4.6.14
ARG CONDA_BUILD_VERSION=3.17.8
ARG CONDA_VERIFY_VERSION=3.1.1
ARG MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh

# Set environment
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV CUDA_HOME=/usr/local/cuda
ENV CC=/usr/bin/gcc-${CC_VERSION}
ENV CXX=/usr/bin/g++-${CXX_VERSION}
ENV CUDAHOSTCXX=/usr/bin/g++-${CXX_VERSION}
ENV PATH=${PATH}:/conda/bin
ENV DEBIAN_FRONTEND=noninteractive

# Update and add pkgs
RUN apt-get update -y --fix-missing && \
      apt-get upgrade -y && \
      apt-get -qq install apt-utils -y --no-install-recommends && \
      apt-get install -y \
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

# Install conda
## Build combined libgdf/pygdf conda env
RUN curl ${MINICONDA_URL} -o /miniconda.sh && \
      sh /miniconda.sh -b -p /conda && \
      rm -f /miniconda.sh && \
      echo "conda ${CONDA_VERSION}" >> /conda/conda-meta/pinned

# Add a condarc to remove blacklist
ADD .condarc /conda/.condarc

# Add utlities to base env
RUN conda install -y \
      codecov \
      conda=${CONDA_VERSION} \
      conda-build=${CONDA_BUILD_VERSION} \
      conda-verify=${CONDA_VERIFY_VERSION}

# Create gdf conda env
RUN conda create --no-default-packages -n gdf \
      python=${PYTHON_VERSION} \
      anaconda-client \
      arrow-cpp=${ARROW_CPP_VERSION} \
      cffi=${CFFI_VERSION} \
      cmake=${CMAKE_VERSION} \
      cmake_setuptools \
      conda=${CONDA_VERSION} \
      conda-build=${CONDA_BUILD_VERSION} \
      conda-verify=${CONDA_VERIFY_VERSION} \
      anaconda::cudatoolkit=${CUDA_SHORT_VERSION} \
      cython=${CYTHON_VERSION} \
      flake8 \
      black \
      isort \
      make \
      numba>=${NUMBA_VERSION} \
      numpy=${NUMPY_VERSION} \
      pandas=${PANDAS_VERSION} \
      pyarrow=${PYARROW_VERSION} \
      double-conversion=${DOUBLE_CONVERSION_VERSION} \
      rapidjson=${RAPIDJSON_VERSION} \
      flatbuffers=${FLATBUFFERS_VERSION} \
      boost-cpp=${BOOST_CPP_VERSION} \
      fastavro=${FASTAVRO_VERSION} \
      dlpack=${DLPACK_VERSION} \
      pytest \
      pytest-cov \
      scikit-learn=${SKLEARN_VERSION} \
      scipy=${SCIPY_VERSION} \
      conda-forge::blas=1.1=openblas \
      libgcc-ng=${LIBGCC_NG_VERSION} \
      libgfortran-ng=${LIBGFORTRAN_NG_VERSION} \
      libstdcxx-ng=${LIBSTDCXX_NG_VERSION} \
      && conda clean -a && \
      chmod 777 -R /conda

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
