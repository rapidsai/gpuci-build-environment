#!/bin/bash
# Copyright (c) 2018, NVIDIA CORPORATION.
##*
## EDIT: Add package names in the comment
################################################
# |<package>| GPU Build and Test Script for CI #
################################################
##*
set -e
NUMARGS=$#
ARGS=$*

# Logger function for build status output
function logger() {
  echo -e "\n>>>> $@\n"
}

# Arg parsing function
function hasArg {
    (( ${NUMARGS} != 0 )) && (echo " ${ARGS} " | grep -q " $1 ")
}

# Set path and build parallel level
export PATH=/conda/bin:/usr/local/cuda/bin:$PATH
export PARALLEL_LEVEL=4
export CUDA_REL=${CUDA_VERSION%.*}

# Set home to the job's workspace
export HOME=$WORKSPACE

# Parse git describe
cd $WORKSPACE
export GIT_DESCRIBE_TAG=`git describe --tags`
export MINOR_VERSION=`echo $GIT_DESCRIBE_TAG | grep -o -E '([0-9]+\.[0-9]+)'`

################################################################################
# SETUP - Check environment
################################################################################

logger "Check environment..."
env

logger "Check GPU usage..."
nvidia-smi

logger "Activate conda env..."
. /opt/conda/etc/profile.d/conda.sh
conda activate rapids
##*
## EDIT: Install all build, runtime, and test dependencies
conda install |<build_dep>| |<runtime_dep>| |<test_dep>|
##*
logger "Check versions..."
python --version
$CC --version
$CXX --version
conda list

##*
## EDIT: Add package names in the comment
################################################################################
# BUILD - Build |<package>| |<package>| |<package>| from source
################################################################################
##*

logger "Build libcudf..."
##*
## EDIT: Build and install all packages available in the rootbuild.sh
$WORKSPACE/build.sh clean |<package>| |<package>| |<package>| 
##*

##*
## EDIT: Add package names to the comment
################################################################################
# TEST - Run GoogleTest and py.tests for |<package>| |<package>| |<package>|
################################################################################
##*

##*
## EDIT: Run all unit tests
if hasArg --skip-tests; then
    logger "Skipping Tests..."
else
    |<call_unit_tests>|
fi
##*

