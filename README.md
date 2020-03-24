# gpuci-build-environment

Common build environment used by gpuCI for building RAPIDS

## Containers

Listed in order of builds and deps

1.  [`gpuci/builds-gcc7`](https://hub.docker.com/r/gpuci/builds-gcc7/tags)
    - From `nvidia/cuda`
    - Purpose
      - Builds gcc7 from source on CentOS 7
      - Used by CentOS 7 images during `gpuci/miniconda-cuda` build to install gcc7 without building
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}`
2.  [`gpuci/miniconda-cuda`](https://hub.docker.com/r/gpuci/miniconda-cuda/tags)
    - From - `nvidia/cuda`
    - Purpose
      - Contains CUDA + miniconda installed
      - Activates the `base` environment on launch
      - Serves as a base container for community and gpuCI users to build their own custom image
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}`
3.  [`gpuci/miniconda-cuda-rapidsenv`](https://hub.docker.com/r/gpuci/miniconda-cuda-rapidsenv/tags)
    - From - `gpuci/miniconda-cuda`
    - Purpose
      - Contains `rapids` conda env with critical base packages installed
        - Not meant for all pkgs only `blas, cudatoolkit, python, libgcc-ng, libstdcxx-ng`
        - This is to help ensure that when installing from `conda-forge` we get the correct ABI pkgs
      - Activates the `rapids` environment on launch
      - Serves as a base container for all RAPIDS images
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}-py{PYTHON_VERSION}`
4.  [`gpuci/rapidsai-build`](https://hub.docker.com/r/gpuci/rapidsai-build/tags)
    - From - `gpuci/miniconda-cuda-rapidsenv`
    - Purpose
      - Base gpuCI image for RAPIDS testing
      - Installs common RAPIDS conda pkgs into the `base` environment
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}-py{PYTHON_VERSION}`
5.  [`gpuci/rapidsai-build-driver`](https://hub.docker.com/r/gpuci/rapidsai-build-driver/tags)
    - From - `gpuci/rapidsai-build`
    - Purpose
      - CPU-only conda builds that need the NVIDIA driver installed for linking
      - Each image has the driver/libcuda installed that matched the CUDA vesion
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}-py{PYTHON_VERSION}`

## Usage

TODO: Update for new container structure

## Best practices

TODO: Specify best practices for what should and should not be in the container
