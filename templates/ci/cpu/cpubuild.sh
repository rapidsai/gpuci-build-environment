#!/bin/bash
# Copyright (c) 2018, NVIDIA CORPORATION.
##*
## EDIT: Add package names in the comment
######################################
# |<package>| CPU conda build script for CI #
######################################
##*
set -e

# Logger function for build status output
function logger() {
  echo -e "\n>>>> $@\n"
}

# Set path and build parallel level
export PATH=/conda/bin:/usr/local/cuda/bin:$PATH
export PARALLEL_LEVEL=4

# Set home to the job's workspace
export HOME=$WORKSPACE

# Switch to project root; also root of repo checkout
cd $WORKSPACE

# Get latest tag and number of commits since tag
export GIT_DESCRIBE_TAG=`git describe --abbrev=0 --tags`
export GIT_DESCRIBE_NUMBER=`git rev-list ${GIT_DESCRIBE_TAG}..HEAD --count`

##*
## OPTIONAL: This code block adds a YYMMDD timestamp to your conda package name
# If nightly build, append current YYMMDD to version
if [[ "$BUILD_MODE" = "branch" && "$SOURCE_BRANCH" = branch-* ]] ; then
  export VERSION_SUFFIX=`date +%y%m%d`
fi
##*

################################################################################
# SETUP - Check environment
################################################################################

logger "Get env..."
env

logger "Activate conda env..."
. /opt/conda/etc/profile.d/conda.sh
conda activate rapids

logger "Check versions..."
python --version
gcc --version
g++ --version
conda list

# FIX Added to deal with Anancoda SSL verification issues during conda builds
conda config --set ssl_verify False

##*
################################################################################
# BUILD - Conda package builds
################################################################################
##*

##*
## EDIT: Use the conda build script to install each package individually
logger "Build conda pkg for |<package>|..."
source ci/cpu/libnvstrings/build_|<package>|.sh

logger "Build conda pkg for |<package>|..."
source ci/cpu/nvstrings/build_|<package>|.sh
##*

################################################################################
# UPLOAD - Conda packages
################################################################################

logger "Upload conda pkgs..."
source ci/cpu/upload_anaconda.sh

