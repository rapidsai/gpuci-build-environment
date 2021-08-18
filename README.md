# gpuci-build-environment

## Overview

This repo contains Docker images used by gpuCI and release images for RAPIDS.
Additional gpuCI users also have custom images in this repo.

Below is a flow diagram of how the major gpuCI images relate to each other.
Arrows between images imply that the source image is the `FROM` image for the
destination image.

### Image Flow Diagram

![gpuCI images and relations](gpuci-images.png)

## Public Images

The `gpuci/miniconda-cuda` image is the base layer that all gpuCI testing and
RAPIDS release containers are built off of. This image also serves as a public
image for those who want a one-to-one compatible `nvidia/cuda` image with
`miniconda` installed. In addition `gpuci/miniconda-cuda-driver` is provided for
`ubuntu18.04` and `centos7` *only* with a minimum set of conda build utilities and the NVIDIA
driver installed to allow for CPU-only conda builds of most CUDA code.

### [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=gpuci%2Fdocker%2Fminiconda-cuda)](https://gpuci.gpuopenanalytics.com/job/gpuci/job/docker/job/miniconda-cuda/) `gpuci/miniconda-cuda`

- Repo location
  - [`gpuci/miniconda-cuda`](https://hub.docker.com/r/gpuci/miniconda-cuda/tags) 
- Dockerfile
  - [`Dockerfile`](miniconda-cuda/Dockerfile)
- Build arguments
  - Depends on upstream `nvidia/cuda` combinations
    - `CUDA_VER` - `9.0`, `9.2`, `10.0`, `10.1`, `10.2`, `11.0`, `11.1`, `11.2`
    - `IMAGE_TYPE` - `base`, `runtime`, `devel`
    - `LINUX_VER` - `ubuntu18.04`, `ubuntu20.04`, `centos7`, `centos8`
  - Other arguments
    - `FROM_IMAGE` - `nvidia/cuda`
- Base image
  - `FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}`
    - Default - `nvidia/cuda:10.2-devel-ubuntu18.04`
- Purpose
  - Contains CUDA + miniconda installed
  - Replaces `nvidia/cuda` and enables conda environment
  - Activates the `base` conda environment on launch
  - Serves as a base image for community using `conda` and gpuCI users to
  build their own custom image
- Tag format - `${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}`
  - Supports the same options as defined in **Build arguments**
  - Current [tags](https://hub.docker.com/r/gpuci/miniconda-cuda/tags)

### [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=gpuci%2Fdocker%2Fminiconda-cuda-driver)](https://gpuci.gpuopenanalytics.com/job/gpuci/job/docker/job/miniconda-cuda-drvier/) `gpuci/miniconda-cuda-driver`

- Repo location
  - [`gpuci/miniconda-cuda-driver`](https://hub.docker.com/r/gpuci/miniconda-cuda-driver/tags) 
- Dockerfile
  - [`Dockerfile`](miniconda-cuda-driver/Dockerfile)
- Build arguments
  - Depends on upstream `nvidia/cuda` combinations
    - `CUDA_VER` - `11.0`, `11.1`, `11.2`
    - `IMAGE_TYPE` - `devel`
    - `LINUX_VER` - `ubuntu18.04`, `centos7`
  - Other arguments
    - `FROM_IMAGE` - `gpuci/miniconda-cuda`
- Base image
  - `FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}`
    - Default - `gpuci/miniconda-cuda:11.0-devel-ubuntu18.04`
- Purpose
  - Adds tools needed for conda builds and uploads
  - Installs the NVIDIA driver for CPU-only builds of most CUDA code
  - Activates the `base` conda environment on launch
- Tag format - `${CUDA_VER}-devel-${LINUX_VER}`
  - Supports the same options as defined in **Build arguments**
  - Current [tags](https://hub.docker.com/r/gpuci/miniconda-cuda-driver/tags)

## gpuCI Images

The images below are used for `conda` builds and GPU tests in gpuCI, see the
[diagram](#image-flow-diagram) above for more context. They are ordered by their
dependencies.

### Supporting Image - `gcc7` From-Source Build for CentOS 7

A supplemental image that is sourced for CentOS 7 images is `gpuci/builds-gcc7`.
This is due to `gcc4` being the standard `gcc` in CentOS 7. With this image we
pre-build `gcc7.3` and then use the following to pull the pre-built files into
an image:

```
# Install gcc7 from prebuilt tarball
wget --quiet https://gpuci.s3.us-east-2.amazonaws.com/builds/gcc7.tgz -O /gcc7.tgz \
    && tar xzvf /gcc7.tgz \
    && rm -f /gcc7.tgz
```

- Repo location
  - [`gpuci/builds-gcc7`](https://hub.docker.com/r/gpuci/builds-gcc7/tags)
- Dockerfile
  - [`Dockerfile.centos7`](builds-gcc7/Dockerfile.centos7)
- Base Image
  - `FROM nvidia/cuda:${CUDA_VER}-${CUDA_TYPE}-${LINUX_VER}`
- Purpose
  - Builds gcc7 from source on CentOS 7
  - Used by CentOS 7 images during `gpuci/miniconda-cuda` build to install gcc7 without building
- Tags - `${CUDA_VER}-${CUDA_TYPE}-${LINUX_VER}`
  - Supports these options
    - `${CUDA_VER}` - `10.2`
    - `${CUDA_TYPE}` - `devel`
    - `${LINUX_VER}` - `centos7`

### GPU Test Images

The `gpuci/rapidsai` images serve different purposes based on their `IMAGE_TYPE`
and their `RAPIDS_VER` version:

### [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=gpuci%2Fdocker%2Frapidsai)](https://gpuci.gpuopenanalytics.com/job/gpuci/job/docker/job/rapidsai/) `gpuci/rapidsai`

- Image types - `IMAGE_TYPE`
  - `devel` - image types are used in gpuCI on nodes with [NVIDIA Container Toolkit](https://github.com/NVIDIA/nvidia-docker)
installed for running tests with GPUs. They are also used by the RAPIDS `devel`
release images and as the base for `gpuci/rapidsai-driver` and `gpuci/rapidsai-driver-nightly`.
  - `runtime` - image types are used by RAPIDS `base` and `runtime` release.
  RAPIDS `base` images do not use the `base` type from `gpuci/miniconda-cuda` or
  `nvidia/cuda` as they do not have all the required files to run RAPIDS.
- Versioning - `RAPIDS_VER`
  - [`gpuci/rapidsai`](https://hub.docker.com/r/gpuci/rapidsai/tags) uses the same versioning as the RAPIDS project
  - The current **stable** version of RAPIDS tracks the **release/stable** [integration](https://github.com/rapidsai/integration/tree/branch-21.06/conda/recipes) `env` packages
  - The current **nightly** version of RAPIDS tracks the **nightly** [integration](https://github.com/rapidsai/integration/tree/branch-21.06/conda/recipes) `env` packages
- Dockerfiles
  - `base` & `runtime`:
    - [`base-runtime.Dockerfile`](rapidsai/base-runtime.Dockerfile)
  - `devel`:
    - Ubuntu 18.04 & 20.04 - [`devel.Dockerfile`](rapidsai/devel.Dockerfile)
    - CentOS 7 & 8 - [`devel-centos7.Dockerfile`](rapidsai/devel-centos.Dockerfile)
- Build arguments
  - `RAPIDS_CHANNEL` - `conda` channel to use for install of integration pkgs
    - `rapidsai` for stable; `rapidsai-nightly` for nightly
  - `RAPIDS_VER` - Major and minor version to use for packages (e.g. `21.06`)
  - `BUILD_STACK_VER` - Specifies the `conda-forge` version of build stack to install
    - Default - `9.4.0` for packages `libgcc-ng` & `libstdcxx-ng`
- Base image
  - `FROM gpuci/miniconda-cuda:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}`
- Purpose
  - Provide a common testing base that can be reused by the RAPIDS release images
  - Use the [integration](https://github.com/rapidsai/integration/tree/branch-21.06/conda/recipes) `env` packages to pull consistent versioning information for all of RAPIDS
    - **NOTE**: These images install the `env` packages to get their
    dependencies, but are **removed** after install in this container. This
    allows the same packages to be installed again later updating the image. It
    also allows PR jobs to use the `devel` image and override dependencies for
    testing purposes. With the `env` packages still installed there would be a
    `conda` solve conflict.
- Tags - `${RAPIDS_VER}-cuda${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}-py${PYTHON_VER}`
  - Supports these options
    - `${RAPIDS_VER}` - Major and minor version of RAPIDS (e.g. `21.06`)
    - `${CUDA_VER}` - `11.0`, `11.2`
    - `${IMAGE_TYPE}` - `base`, `runtime`, `devel`
    - `${LINUX_VER}` - `ubuntu18.04`, `ubuntu20.04`, `centos7`, `centos8`
    - `${PYTHON_VER}` - `3.7`, `3.8`

#### `conda` Build Images

The `gpuci/rapidsai-driver` and images are used to build `conda` packages on
*CPU-only* machines. They are from the `devel` images of `gpuci/rapidsai`. To
enable some of the RAPIDS builds on CPU-only machines we leverage this container
by force installing the NVIDIA drivers. This allows us to have the necessary
files for linking during the build steps.

### [![Build Status](https://gpuci.gpuopenanalytics.com/buildStatus/icon?job=gpuci%2Fdocker%2Frapidsai-driver)](https://gpuci.gpuopenanalytics.com/job/gpuci/job/docker/job/rapidsai-driver/) `gpuci/rapidsai-driver`

- Versioning - `RAPIDS_VER`
  - Similar to `gpuci/rapidsai` these images use the RAPIDS versioning
  - [`gpuci/rapidsai-driver`](https://hub.docker.com/r/gpuci/rapidsai-driver/tags) - similar to `gpuci/rapidsai` use the same versioning as the RAPIDS project
  - The current **stable** version of RAPIDS tracks the **release/stable** [integration](https://github.com/rapidsai/integration/tree/branch-21.06/conda/recipes) `env` packages
  - The current **nightly** version of RAPIDS tracks the **nightly** [integration](https://github.com/rapidsai/integration/tree/branch-21.06/conda/recipes) `env` packages
- Dockerfile
  - CentOS 7 - [`Dockerfile`](rapidsai-driver/centos.Dockerfile)
- Build arguments
  - `FROM_IMAGE` - Specifies the repo location; stable/nightly is determined by the value of `RAPIDS_VER`
  - `DRIVER_VER` - NVIDIA driver version to install (i.e. `440`)
  - `CUDA_VER` and `PYTHON_VER` - Take the same arguments as defined in **Tags** below
  - `RAPIDS_VER` - This is used to select the `FROM_IMAGE`
- Base image
  - `FROM gpuci/rapidsai:${RAPIDS_VER}-cuda${CUDA_VER}-devel-ubuntu16.04-py${PYTHON_VERSION}`
- Purpose
  - Installs the NVIDIA driver/libcuda to enable conda builds on CPU-only machines
  - Built for conda builds and only contains the driver install command
  - Maintained as a way to remove the `apt-get install` overhead that can slow the testing/build process
- Tags - `${RAPIDS_VER}-cuda${CUDA_VER}-devel-centos7-py${PYTHON_VER}`
  - Supports these options
    - `${RAPIDS_VER}` - Major and minor version of RAPIDS (e.g. `21.06`)
    - `${CUDA_VER}` - `11.0`, `11.2`
    - `${PYTHON_VER}` - `3.7`, `3.8`

## RAPIDS Images

The RAPIDS release images are based off of the `gpuci/rapidsai` images for
*stable/release* images and based off of the `gpuci/rapidsai-nightly` images for
*nightly* images. Scripts and templates for these images are maintained in the
[build](https://github.com/rapidsai/build) repo.

For a list of available images see the RAPIDS [build README](https://github.com/rapidsai/build#image-types).
