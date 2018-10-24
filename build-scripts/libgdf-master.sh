#!/bin/bash
set -e
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

if [ -d "$WORKSPACE/libgdf" ] ; then
  logger "Subfolder detected, entering for build..."
  cd libgdf
fi

logger "Run cmake libgdf..."
rm -rf build
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX -DHASH_JOIN=ON

logger "Run make libgdf..."
make -j4 install

logger "Install libgdf for Python..."
make -j4 copy_python
python setup.py install

logger "Check GPU usage..."
nvidia-smi

logger "GoogleTest for libgdf..."
GTEST_OUTPUT="xml:${WORKSPACE}/test-results/" make -j test

logger "Python py.test for libgdf..."
cd ${WORKSPACE}
py.test --cache-clear --junitxml=junit.xml -v
cp junit.xml $WORKSPACE/test-results
