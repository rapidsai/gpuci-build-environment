#!/bin/bash
set -e
LIBGDF_REPO=https://github.com/gpuopenanalytics/libgdf

function logger() {
  echo -e "\n>>>> $@\n"
}

logger "Check environment..."
env

logger "Check GPU usage..."
nvidia-smi

logger "Activate conda env..."
source activate gdf

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
cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX ..

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
