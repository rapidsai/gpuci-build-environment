# gpuci-build-environment

## Overview

This repo contains Docker images used by gpuCI and release images for RAPIDS.
Additional gpuCI users also have custom images in this repo.

Below is a flow diagram of how the major gpuCI images relate to each other.
Arrows between images imply that the source image is the `FROM` image for the
destination image.

### Image Flow Diagram

![gpuCI images and relations](gpuci-images.png)

## Base Image

The `gpuci/miniconda-cuda` image is the base layer that all gpuCI testing and
RAPIDS release containers are built off of. Below is a description of the image
and how it is built.

<!-- TODO update build status icons -->
[`gpuci/miniconda-cuda`](https://hub.docker.com/r/gpuci/miniconda-cuda/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Fgpuci-miniconda-cuda)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/gpuci-miniconda-cuda/)
  - Dockerfiles
    - Ubuntu 16.04 & 18.04 - [`Dockerfile`](miniconda-cuda/Dockerfile)
    - CentOS 7 - [`Dockerfile.centos7`](miniconda-cuda/Dockerfile.centos7)
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

## gpuCI Build & Test Images

The images below are used for `conda` builds and GPU tests in gpuCI. They are
ordered by their dependencies. See the [diagram](#image-flow-diagram)
above for more context.

### `gcc7` From-Source Build for CentOS 7

A supplemental image that is sourced for CentOS 7 images is `gpuci/builds-gcc7`.
This is due to `gcc4` being the standard `gcc` in CentOS 7. With this image we
pre-build `gcc7.3` and then use the following to pull the pre-built files into
an image:

```
# Install gcc7 from prebuilt image
COPY --from=gpuci/builds-gcc7:10.0-devel-centos7 /usr/local/gcc7 /usr/local/gcc7
```

[`gpuci/builds-gcc7`](https://hub.docker.com/r/gpuci/builds-gcc7/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Fgpuci-builds-gcc7)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/gpuci-builds-gcc7/)
  - Dockerfile
    - [`Dockerfile.centos7`](builds-gcc7/Dockerfile.centos7)
  - Base Image
    - `FROM nvidia/cuda:${CUDA_VER}-${CUDA_TYPE}-${LINUX_VER}`
  - Purpose
    - Builds gcc7 from source on CentOS 7
    - Used by CentOS 7 images during `gpuci/miniconda-cuda` build to install gcc7 without building
  - Tags - `${CUDA_VER}-${CUDA_TYPE}-${LINUX_VER}`
    - Supports these options
      - `${CUDA_VER}` - `10.0`, `10.1`, `10.2`
      - `${CUDA_TYPE}` - `devel`
      - `${LINUX_VER}` - `centos7`

### GPU Test Images

The `gpuci/rapidsai` images serve different purposed based on their `CUDA_TYPE`:
- `devel` - image types are used in gpuCI on nodes with [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)
installed for running tests with GPUs. They are also used by the RAPIDS `devel`
release images.
- `base` & `runtime` - image types are used by their respective RAPIDS `base`
and `runtime` release images.

[`gpuci/rapidsai`](https://hub.docker.com/r/gpuci/rapidsai-base/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Frapidsai-base)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/rapidsai-base/)
  - Dockerfiles
    - Ubuntu 16.04 & 18.04 - [`Dockerfile`](gpuci/rapidsai/Dockerfile)
    - CentOS 7 - [`Dockerfile.centos7`](gpuci/rapidsai/Dockerfile.centos7)
  - Base image
    - `FROM gpuci/miniconda-cuda:${CUDA_VER}-${CUDA_TYPE}-${LINUX_VER}`
  - Purpose
    - ...
  - Tags - `${CUDA_VER}-${CUDA_TYPE}-${LINUX_VER}-py${PYTHON_VER}`
    - Supports these options
      - `${CUDA_VER}` - `10.0`, `10.1`, `10.2`
      - `${CUDA_TYPE}` - `base`, `runtime`, `devel`
      - `${LINUX_VER}` - `ubuntu16.04`, `ubuntu18.04`, `centos7`
      - `${PYTHON_VER}` - `3.6`, `3.7`

### `conda` Build Images
2.  [`gpuci/rapidsai-driver`](https://hub.docker.com/r/gpuci/rapidsai-base-driver/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Frapidsai-base-driver)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/rapidsai-base-driver/)
    - Dockerfiles
      - Ubuntu 16.04 & Ubuntu 18.04 - [`Dockerfile.drivers`](rapidsai/Dockerfile.drivers)
    - Base image
      - `FROM gpuci/rapidsai:${CUDA_VER}-devel-${LINUX_VER}-py${PYTHON_VERSION}`
    - Purpose
      - Installs the NVIDIA driver/libcuda to enable conda builds on CPU-only machines
      - Built for conda builds and only contains the driver install command
      - Maintained as a way to remove the `apt-get install` overhead that can slow the testing/build process
    - Tags - `${CUDA_VER}-devel-${LINUX_VER}-py${PYTHON_VER}`
    - Supports these options
      - `${CUDA_VER}` - `10.0`, `10.1`, `10.2`
      - `${CUDA_TYPE}` - `devel`
      - `${LINUX_VER}` - `ubuntu16.04`, `ubuntu18.04`, `centos7`
      - `${PYTHON_VER}` - `3.6`, `3.7`

## RAPIDS Release Containers

**NOTE:** These are on branch [enh-miniconda-cuda-df](https://github.com/rapidsai/gpuci-build-environment/tree/enh-miniconda-cuda-df) for the time being until they can be merged into the gpuCI testing containers

Listed in order of builds and deps

1.  [`gpuci/builds-gcc7`](https://hub.docker.com/r/gpuci/builds-gcc7/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Fgpuci-builds-gcc7)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/gpuci-builds-gcc7/)
    - From `nvidia/cuda`
    - Purpose
      - Builds gcc7 from source on CentOS 7
      - Used by CentOS 7 images during `gpuci/miniconda-cuda` build to install gcc7 without building
    - Tags - `{CUDA_VER}-{CUDA_TYPE}-{LINUX_VER}`
2.  [`gpuci/miniconda-cuda`](https://hub.docker.com/r/gpuci/miniconda-cuda/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Fgpuci-miniconda-cuda)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/gpuci-miniconda-cuda/)
    - From - `nvidia/cuda`
    - Purpose
      - Contains CUDA + miniconda installed
      - Activates the `base` environment on launch
      - Serves as a base container for community and gpuCI users to build their own custom image
    - Tags - `{CUDA_VER}-{CUDA_TYPE}-{LINUX_VER}`
3.  [`gpuci/miniconda-cuda-rapidsenv`](https://hub.docker.com/r/gpuci/miniconda-cuda-rapidsenv/tags)
    [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=docker%2Fdockerhub-gpuci%2Fgpuci-miniconda-cuda-rapidsenv)](https://gpuci.gpuopenanalytics.com/view/gpuCI%20docker-builds/job/docker/job/dockerhub-gpuci/job/gpuci-miniconda-cuda-rapidsenv/)
    - From - `gpuci/miniconda-cuda`
    - Purpose
      - Contains `rapids` conda env with critical base packages installed
        - Not meant for all pkgs only `blas, cudatoolkit, python, libgcc-ng, libstdcxx-ng`
        - This is to help ensure that when installing from `conda-forge` we get the correct ABI pkgs
      - Activates the `rapids` environment on launch
      - Serves as a base container for all RAPIDS images
    - Tags - `{CUDA_VER}-{CUDA_TYPE}-{LINUX_VER}-py{PYTHON_VERSION}`
