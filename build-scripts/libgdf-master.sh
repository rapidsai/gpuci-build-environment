#!/bin/bash
set -e
function logger() {
  echo -e "\n>>>> $@\n"
}

logger "Check environment..."
env

logger "Check GPU usage..."
nvidia-smi

logger "Patch conda env..."
cat conda_environments/dev_py35.yml | grep -v "cudatoolkit" > libgdf_dev.yml

logger "Create conda env..."
rm -rf /home/jenkins/.conda/envs/libgdf_dev
conda env create --name libgdf_dev --file libgdf_dev.yml

logger "Activate conda env..."
source activate libgdf_dev

logger "Check versions..."
python --version
gcc --version
g++ --version
conda list

logger "Run cmake libgdf..."
rm -rf build
mkdir build
cd build
cmake .. -DHASH_JOIN=ON

logger "Run make libgdf..."
make -j install

logger "Install libgdf for Python..."
make -j copy_python
python setup.py install

logger "Check GPU usage..."
nvidia-smi

logger "GoogleTest for libgdf..."
GTEST_OUTPUT="xml:${WORKSPACE}/test-results/" make -j test

logger "Python py.test for libgdf..."
cd ${WORKSPACE}
py.test --cache-clear --junitxml=junit.xml -v
cp junit.xml $WORKSPACE/test-results
