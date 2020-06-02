#!/usr/bin/env bash

V=8

echo "Using gcc-$V and g++-$V"
export GCC_VERSION="$V"
export CXX_VERSION="$V"
export NVCC="/usr/local/bin/nvcc"
export CC="/usr/local/bin/gcc-$GCC_VERSION"
export CXX="/usr/local/bin/g++-$CXX_VERSION"
echo "rapids" | sudo -S update-alternatives --set gcc /usr/bin/gcc-${GCC_VERSION} >/dev/null 2>&1;
echo "rapids" | sudo -S update-alternatives --set g++ /usr/bin/g++-${CXX_VERSION} >/dev/null 2>&1;

# Create or remove ccache compiler symlinks
echo "rapids" | sudo -S ln -s -f "$(which ccache)" "/usr/local/bin/gcc"                        >/dev/null 2>&1;
echo "rapids" | sudo -S ln -s -f "$(which ccache)" "/usr/local/bin/nvcc"                       >/dev/null 2>&1;
echo "rapids" | sudo -S ln -s -f "$(which ccache)" "/usr/local/bin/gcc-$GCC_VERSION"           >/dev/null 2>&1;
echo "rapids" | sudo -S ln -s -f "$(which ccache)" "/usr/local/bin/g++-$CXX_VERSION"           >/dev/null 2>&1;
