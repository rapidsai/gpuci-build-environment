ARG FROM_IMAGE=nvidia/cuda
ARG CUDA_VERSION=9.2
ARG CUDA_SHORT_VERSION=${CUDA_VERSION}
ARG LINUX_VERSION=ubuntu16.04
FROM ${FROM_IMAGE}:${CUDA_VERSION}-devel-${LINUX_VERSION}

# Define arguments
ARG CUDA_SHORT_VERSION
ARG CC_VERSION=5
ARG CXX_VERSION=5
ARG PYTHON_VERSION=3.6
ARG CFFI_VERSION=1.11.5
ARG CUPY_VERSION=6.6.0
ARG CYTHON_VERSION=0.29
ARG CMAKE_VERSION=3.14.5
ARG NUMBA_VERSION=0.46.0
ARG NUMPY_VERSION=1.17.3
ARG PANDAS_VERSION=0.25
ARG PYARROW_VERSION=0.15.0
ARG ARROW_CPP_VERSION=0.15.0
ARG DOUBLE_CONVERSION_VERSION=3.1.5
ARG RAPIDJSON_VERSION=1.1.0
ARG FLATBUFFERS_VERSION=1.10.0
ARG BOOST_CPP_VERSION=1.70.0
ARG FASTAVRO_VERSION=0.22.3
ARG DLPACK_VERSION=0.2
ARG SKLEARN_VERSION=0.21.3
ARG SCIPY_VERSION=1.3.0
ARG LIBGCC_NG_VERSION=7.3.0
ARG LIBGFORTRAN_NG_VERSION=7.3.0
ARG LIBSTDCXX_NG_VERSION=7.3.0
ARG LIBCLANG_VERSION=8.0.0
ARG LIBRDKAFKA_VERSION=1.2.2
ARG OPENBLAS_VERSION=2.14
ARG TINI_VERSION=v0.18.0
ARG HASH_JOIN=ON
ARG CONDA_VERSION=4.7.12
ARG CONDA_BUILD_VERSION=3.18.11
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
        awscli \
        curl \
        git \
        jq \
        screen \
        gcc-${CC_VERSION} \
        g++-${CXX_VERSION} \
        libnuma1 \
        libnuma-dev \
        tzdata \
        wget \
        vim \
        zlib1g-dev \
      && rm -rf /var/lib/apt/lists/*

# Install conda
RUN curl ${MINICONDA_URL} -k -o /miniconda.sh \
      && sh /miniconda.sh -b -p /conda \
      && rm -f /miniconda.sh \
      && echo "conda ${CONDA_VERSION}" >> /conda/conda-meta/pinned

# Add a condarc
ADD .condarc /conda/.condarc

# Add utlities to base env
RUN conda install -y \
      anaconda-client \
      codecov \
      conda=${CONDA_VERSION} \
      conda-build=${CONDA_BUILD_VERSION} \
      conda-verify=${CONDA_VERIFY_VERSION} \
      ripgrep

# Create gdf conda env
RUN conda create --no-default-packages -n gdf \
      python=${PYTHON_VERSION} \
      arrow-cpp=${ARROW_CPP_VERSION} \
      cffi=${CFFI_VERSION} \
      cmake=${CMAKE_VERSION} \
      cmake_setuptools \
      conda=${CONDA_VERSION} \
      conda-build=${CONDA_BUILD_VERSION} \
      conda-verify=${CONDA_VERIFY_VERSION} \
      cudatoolkit=${CUDA_SHORT_VERSION} \
      cupy=${CUPY_VERSION} \
      cython=${CYTHON_VERSION} \
      flake8 \
      black \
      isort \
      make \
      numba">=${NUMBA_VERSION}" \
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
      conda-forge::blas=${OPENBLAS_VERSION}=openblas \
      libgcc-ng=${LIBGCC_NG_VERSION} \
      libgfortran-ng=${LIBGFORTRAN_NG_VERSION} \
      libstdcxx-ng=${LIBSTDCXX_NG_VERSION} \
      rapidsai::libclang=${LIBCLANG_VERSION} \
      librdkafka=${LIBRDKAFKA_VERSION} \
      twine \
    && conda clean -afy \
    && chmod -R ugo+w /conda

## Patch nvidia-smi to return only 0 exit codes
RUN mv /usr/bin/nvidia-smi /usr/bin/nvidia-smi-orig \
    && echo 'nvidia-smi-orig $@ || true' > /usr/bin/nvidia-smi \
    && chmod +x /usr/bin/nvidia-smi

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

RUN curl -L https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini -o /usr/bin/tini && \
      chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
