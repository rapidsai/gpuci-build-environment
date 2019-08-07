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
      - Serves as the base for all new gpuCI and RAPIDS distro images
      - Contains CUDA + miniconda installed with the specified Python version
      - Activates the `base` environment on launch
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}-py{PYTHON_VERSION}`
3.  [`gpuci/rapidsai-minicuda`](https://hub.docker.com/r/gpuci/rapidsai-minicuda/tags)
    - From - `gpuci/miniconda-cuda`
    - Purpose
      - Base gpuCI image for RAPIDS testing
      - Installs common RAPIDS conda pkgs into the `base` environment
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}-py{PYTHON_VERSION}`
4.  [`gpuci/rapidsai-minicuda-driver`](https://hub.docker.com/r/gpuci/rapidsai-minicuda-driver/tags)
    - From - `gpuci/rapidsai-minicuda`
    - Purpose
      - CPU-only conda builds that need the NVIDIA driver installed for linking
      - Each image has the driver/libcuda installed that matched the CUDA vesion
    - Tags - `{CUDA_VERSION}-{CUDA_TYPE}-{LINUX_VERSION}-py{PYTHON_VERSION}`

## Usage

TODO: Update for new container structure

## Best practices

TODO: Specify best practices for what should and should not be in the container
