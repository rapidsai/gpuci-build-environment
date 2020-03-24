ARG CUDA_VERSION=9.2
ARG CUDA_VER=${CUDA_VERSION}
ARG CUDA_TYPE=devel
ARG LINUX_VERSION=ubuntu16.04
ARG PYTHON_VERSION=3.6
FROM gpuci/miniconda-cuda-rapidsenv:${CUDA_VERSION}-${CUDA_TYPE}-${LINUX_VERSION}-py${PYTHON_VERSION}

# Pull arguments above FROM
ARG CUDA_VER
ARG PYTHON_VERSION

# gcc/g++ environment config args
ARG CC_VERSION=5
ARG CXX_VERSION=5

# Core build pkgs with versions
ARG BOOST_CPP_VERSION=1.70.0
ARG CMAKE_VERSION=3.14.5
ARG CONDA_BUILD_VERSION=3.17.8
ARG CONDA_VERIFY_VERSION=3.1.1
ARG LIBGFORTRAN_NG_VERSION=7.3.0
ARG NUMBA_VERSION=0.45.1
ARG NUMPY_VERSION=1.16.4
ARG PANDAS_VERSION=0.24.2

# Dynamic dep install specs
ARG DASK_XGBOOST_CONDA_VERSION_SPEC=0.2*
ARG RAPIDS_CONDA_VERSION_SPEC=0.9*
ARG XGBOOST_CONDA_VERSION_SPEC=0.90.rapidsdev1
ARG XGBOOST_CONDA_LABEL=rapidsai/label/xgboost
ARG XGBOOST_VERSION=0.90

# Update and install gcc/g++
RUN apt-get update \
    && apt-get install -y \
      gcc-${CC_VERSION} \
      g++-${CXX_VERSION} \
    && rm -rf /var/lib/apt/lists/*

# Update environment to use new gcc
ENV CC=/usr/bin/gcc-${CC_VERSION}
ENV CXX=/usr/bin/g++-${CXX_VERSION}
ENV CUDAHOSTCXX=/usr/bin/g++-${CXX_VERSION}
ENV PATH=${PATH}:/conda/bin

# Install common pkgs into base
RUN conda install -y -n base --freeze-installed --override-channels \
      -c numba \
      -c conda-forge \
      -c anaconda \
      anaconda-client \
      codecov \
      conda-build=${CONDA_BUILD_VERSION} \
      conda-verify=${CONDA_VERIFY_VERSION} \
      flake8 \
      black \
      isort \
      make \
      pytest \
      pytest-cov

# Install core dev pkgs, these aren't
RUN source activate rapids \
    && env \
    && conda list \
    && conda install -y -n rapids --freeze-installed --override-channels \
      -c rapidsai \
      -c rapidsai-nightly \
      -c numba \
      -c conda-forge \
      -c anaconda \
      boost-cpp=${BOOST_CPP_VERSION} \
      cmake=${CMAKE_VERSION} \
      cmake_setuptools">=0.1.3" \
      double-conversion \
      dlpack \
      flatbuffers \
      lapack \
      rapidsai::libclang \
      libgfortran-ng=${LIBGFORTRAN_NG_VERSION} \
      liblapack \
      numba=${NUMBA_VERSION} \
      numpy=${NUMPY_VERSION} \
      pandas=${PANDAS_VERSION} \
      rapidjson

# Special case: libcumlmg is not available for CUDA 9.2
RUN if [ "${CUDA_VER}" != "9.2" ]; then conda install -y --no-deps -c nvidia -c conda-forge libcumlmg; fi

# Install deps for all pkgs and remove the pkgs that were installed due to 
# cross library deps
#
# TODO - track when the openblas reinstall doesn't need to happen, w/o it cuml
#        builds are unable to find lapack due to scikit learn install messing
#        with the shared libraries
RUN source activate rapids \
    && env \
    && conda list \
    && conda install -y -n rapids --freeze-installed --override-channels --only-deps \
         -c rapidsai \
         -c rapidsai-nightly \
         -c nvidia \
         -c ${XGBOOST_CONDA_LABEL} \
         -c numba \
         -c conda-forge \
         cudf=${RAPIDS_CONDA_VERSION_SPEC} \
         cuml=${RAPIDS_CONDA_VERSION_SPEC} \
         cugraph=${RAPIDS_CONDA_VERSION_SPEC} \
         dask-cuda=${RAPIDS_CONDA_VERSION_SPEC} \
         dask-xgboost=${DASK_XGBOOST_CONDA_VERSION_SPEC} \
         xgboost=${XGBOOST_VERSION} \
    && conda remove --force \
         rmm librmm \
         nvstrings libnvstrings \
         cudf dask-cudf libcudf \
         cuml libcuml \
         cugraph libcugraph \
         xgboost py-xgboost libxgboost \
    && conda install -y -n rapids --force-reinstall --override-channels \
         -c conda-forge \
         conda-forge::blas==1.1=openblas \
    && ln -s /opt/conda/envs/rapids /opt/conda/envs/gdf \
    && conda clean -afy \
    && source activate base \
    && conda clean -afy \
    && chmod -R ugo+w /opt/conda

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
