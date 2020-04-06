# gpuci-build-environment

## Overview

This repo contains Docker images used by gpuCI and release images for RAPIDS.
Additional gpuCI users also have custom images in this repo.

Below is a flow diagram of how the major gpuCI images relate to each other.
Arrows between images imply that the source image is the `FROM` image for the
destination image.

![gpuCI images and relations](gpuci-images.png)

## Base Image

The `gpuci/miniconda-cuda` image is the base layer that all gpuCI testing and
RAPIDS release containers are built off of. Below is a description of the image
and how it is built.

[`gpuci/miniconda-cuda`](https://hub.docker.com/r/gpuci/miniconda-cuda/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Fgpuci-miniconda-cuda)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/gpuci-miniconda-cuda/)
  - Dockerfiles
    - Ubuntu 16.04 & 18.04 - [`Dockerfile`](gpuci/miniconda-cuda/Dockerfile)
    - CentOS 7 - [`Dockerfile.centos7`](gpuci/miniconda-cuda/Dockerfile.centos7)
  - Base image
    - `FROM nvidia/cuda:${CUDA_VER}-{$CUDA_TYPE}-${LINUX_VER}`
  - Purpose
    - Contains CUDA + miniconda installed
    - Replaces `nvidia/cuda` and enables conda environment
    - Activates the `base` conda environment on launch
    - Serves as a base image for community using `conda` and gpuCI users to
    build their own custom image
  - Tags - `${CUDA_VER}-${CUDA_TYPE}-${LINUX_VER}`
    - Supports these options
      - `${CUDA_VER}` - `9.0`, `9.2`, `10.0`, `10.1`, `10.2`
      - `${CUDA_TYPE}` - `base`, `runtime`, `devel`
      - `${LINUX_VER}` - `ubuntu16.04`, `ubuntu18.04`, `centos7`

## gpuCI Containers

Listed in order of builds and deps

1.  [`gpuci/rapidsai-base`](https://hub.docker.com/r/gpuci/rapidsai-base/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Frapidsai-base)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/rapidsai-base/)
    - Dockerfiles
      - Ubuntu 16.04 & 18.04 - `Dockerfile`
      - CentOS 7 - `Dockerfile.centos7`
    - Base image
      - `FROM nvidia/cuda:${CUDA_VERSION}-devel-${LINUX_VERSION}`
    - Purpose
      - Installs miniconda with select conda build packages into `base` conda env
      - Creates a RAPIDS conda env named `gdf` that has several common packages needed for build across the libraries
        - Also has large packages like `cudatoolkit` to save time on testing from waiting on downloads
      - Run `source activate gdf` before building or testing RAPIDS
    - Tags - `cuda{CUDA_VERSION}-{LINUX_VERSION}-gcc{CC_VERSION}-py{PYTHON_VERSION}`
2.  [`gpuci/rapidsai-base-driver`](https://hub.docker.com/r/gpuci/rapidsai-base-driver/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Frapidsai-base-driver)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/rapidsai-base-driver/)
    - Dockerfiles
      - Ubuntu 16.04 - `Dockerfile.drivers`
    - Base image
      - `FROM gpuci/rapidsai-base:cuda${CUDA_VERSION}-${LINUX_VERSION}-gcc${CC_VERSION}-py${PYTHON_VERSION}`
    - Purpose
      - Installs the NVIDIA driver/libcuda to enable conda builds on CPU-only machines
      - Built for conda builds and only contain the driver install command; otherwise the conda env `gdf` is the same as `gpuci/rapidsai-base`
      - Maintained as a way to remove the `apt-get install` overhead that can slow the testing/build process
    - Tags - `cuda{CUDA_VERSION}-{LINUX_VERSION}-gcc{CC_VERSION}-py{PYTHON_VERSION}`

## Release Containers

**NOTE:** These are on branch [enh-miniconda-cuda-df](https://github.com/rapidsai/gpuci-build-environment/tree/enh-miniconda-cuda-df) for the time being until they can be merged into the gpuCI testing containers

Listed in order of builds and deps

1.  [`gpuci/builds-gcc7`](https://hub.docker.com/r/gpuci/builds-gcc7/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Fgpuci-builds-gcc7)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/gpuci-builds-gcc7/)
    - From `nvidia/cuda`
    - Purpose
      - Builds gcc7 from source on CentOS 7
      - Used by CentOS 7 images during `gpuci/miniconda-cuda` build to install gcc7 without building
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}`
2.  [`gpuci/miniconda-cuda`](https://hub.docker.com/r/gpuci/miniconda-cuda/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Fgpuci-miniconda-cuda)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/gpuci-miniconda-cuda/)
    - From - `nvidia/cuda`
    - Purpose
      - Contains CUDA + miniconda installed
      - Activates the `base` environment on launch
      - Serves as a base container for community and gpuCI users to build their own custom image
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}`
3.  [`gpuci/miniconda-cuda-rapidsenv`](https://hub.docker.com/r/gpuci/miniconda-cuda-rapidsenv/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Fgpuci-miniconda-cuda-rapidsenv)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/gpuci-miniconda-cuda-rapidsenv/)
    - From - `gpuci/miniconda-cuda`
    - Purpose
      - Contains `rapids` conda env with critical base packages installed
        - Not meant for all pkgs only `blas, cudatoolkit, python, libgcc-ng, libstdcxx-ng`
        - This is to help ensure that when installing from `conda-forge` we get the correct ABI pkgs
      - Activates the `rapids` environment on launch
      - Serves as a base container for all RAPIDS images
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}-py{PYTHON_VERSION}`
