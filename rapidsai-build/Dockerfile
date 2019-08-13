ARG CUDA_VERSION=9.2
ARG CUDA_MAJORMINOR_VERSION=${CUDA_VERSION}
ARG CUDA_TYPE=devel
ARG LINUX_VERSION=ubuntu16.04
ARG PYTHON_VERSION=3.6
FROM gpuci/miniconda-cuda:${CUDA_VERSION}-${CUDA_TYPE}-${LINUX_VERSION}-py${PYTHON_VERSION}

# Define arguments
ARG CUDA_MAJORMINOR_VERSION
ARG PYTHON_VERSION
ARG CC_VERSION=5
ARG CXX_VERSION=5
ARG PYTHON_VERSION=3.6
ARG CFFI_VERSION=1.11.5
ARG CYTHON_VERSION=0.29
ARG CMAKE_VERSION=3.12
ARG NUMBA_VERSION=0.44
ARG NUMPY_VERSION=1.16.2
ARG PANDAS_VERSION=0.23.4
ARG PYARROW_VERSION=0.12.1
ARG ARROW_CPP_VERSION=0.12.1
ARG SKLEARN_VERSION=0.20.3
ARG SCIPY_VERSION=1.2.1
ARG LIBGCC_NG_VERSION=7.3.0
ARG LIBGFORTRAN_NG_VERSION=7.3.0
ARG LIBSTDCXX_NG_VERSION=7.3.0
ARG CONDA_VERSION=4.6.14
ARG CONDA_BUILD_VERSION=3.17.8
ARG CONDA_VERIFY_VERSION=3.1.1

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
RUN apt-get update -y --fix-missing \
    && apt-get upgrade -y \
    && apt-get -qq install apt-utils -y --no-install-recommends \
    && apt-get install -y \
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

# Add .condarc file
ADD .condarc /conda/.condarc

# Install conda
RUN conda install -y -n base \
      nomkl \
      anaconda-client \
      arrow-cpp=${ARROW_CPP_VERSION} \
      cffi=${CFFI_VERSION} \
      cmake=${CMAKE_VERSION} \
      codecov \
      conda=${CONDA_VERSION} \
      conda-build=${CONDA_BUILD_VERSION} \
      conda-verify=${CONDA_VERIFY_VERSION} \
      cudatoolkit=${CUDA_MAJORMINOR_VERSION} \
      cython=${CYTHON_VERSION} \
      flake8 \
      black \
      isort \
      make \
      numba>=${NUMBA_VERSION} \
      numpy=${NUMPY_VERSION} \
      pandas=${PANDAS_VERSION} \
      pyarrow=${PYARROW_VERSION} \
      pytest \
      pytest-cov \
      python=${PYTHON_VERSION} \
      scikit-learn=${SKLEARN_VERSION} \
      scipy=${SCIPY_VERSION} \
      conda-forge::blas=1.1=openblas \
      libgcc-ng=${LIBGCC_NG_VERSION} \
      libgfortran-ng=${LIBGFORTRAN_NG_VERSION} \
      libstdcxx-ng=${LIBSTDCXX_NG_VERSION} \
    && conda clean -afy \
    && chmod -R ugo+w /opt/conda

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
