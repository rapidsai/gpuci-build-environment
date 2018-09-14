#!/bin/bash
set -e
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
CC=/usr/bin/gcc
CXX=/usr/bin/g++
LIBGDF_REPO=https://github.com/gpuopenanalytics/libgdf
NUMBA_VERSION=0.40.0
NUMPY_VERSION=1.14.5
PANDAS_VERSION=0.20.3
PYTHON_VERSION=3.5
PYARROW_VERSION=0.10.0

function logger() {
  echo -e "\n>>>> $@\n"
}

logger "Check environment..."
env

logger "Check GPU usage..."
nvidia-smi

logger "Create conda env..."
rm -rf /home/jenkins/.conda/envs/pygdf
conda create -n pygdf python=${PYTHON_VERSION}
conda install -n pygdf -y -c numba -c conda-forge -c defaults \
  numba=${NUMBA_VERSION} \
  numpy=${NUMPY_VERSION} \
  pandas=${PANDAS_VERSION} \
  pyarrow=${PYARROW_VERSION} \
  pytest

logger "Activate conda env..."
source activate pygdf

logger "Check versions..."
python --version
gcc --version
g++ --version
conda list

logger "Clone libgdf..."
rm -rf $WORKSPACE/libgdf
git clone --recurse-submodules ${LIBGDF_REPO} $WORKSPACE/libgdf

logger "Build libgdf..."
mkdir -p $WORKSPACE/libgdf/build
cd $WORKSPACE/libgdf/build
logger "Run cmake libgdf..."
cmake ..

logger "Clean up make..."
make clean

logger "Install libgdf..."
make -j install

logger "Install libgdf for Python..."
make -j copy_python
python setup.py install

logger "Build pygdf..."
cd $WORKSPACE
python setup.py install

logger "Check GPU usage..."
nvidia-smi

logger "Test pygdf..."
py.test --cache-clear --junitxml=junit.xml --ignore=libgdf -v
