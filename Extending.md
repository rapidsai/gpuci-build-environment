# How can I create images to build my project on gpuCI?

gpuCI can use any docker images to build your project. However, the RAPIDS Ops team has some prebuilt parent images which make things easier especially if you depende on CUDA and Conda.

Supported OS:
* ubuntu16.04
* ubuntu18.04
* centos7

CUDA:
* 9.0
* 9.2
* 10.0
* 10.1
* 10.2

Please check the tags for the full availability here: https://hub.docker.com/r/gpuci/miniconda-cuda/tags

Here is the Dockerfiles you can extend: https://github.com/rapidsai/gpuci-build-environment/tree/enh-miniconda-cuda-df/miniconda-cuda

Here is a barebones example on extending the image:

```Dockerfile
ARG FROM_IMAGE=gpuci/miniconda-cuda
ARG CUDA_VERSION=9.2
ARG CUDA_VER=${CUDA_VERSION}
ARG CUDA_TYPE=devel
ARG LINUX_VERSION=ubuntu16.04
FROM ${FROM_IMAGE}:${CUDA_VERSION}-${CUDA_TYPE}-${LINUX_VERSION}

# Define arguments
ARG CUDA_VER
ARG PYTHON_VERSION=3.6
ARG LIB_NG_VERSION=7.3.0

# Set environment
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV PATH=${PATH}:/conda/bin

# Create a dev conda env
RUN source activate base \
    && conda create --no-default-packages --override-channels -n dev \
      -c nvidia \
      -c conda-forge \
      -c defaults \
      nomkl \
      cudatoolkit=${CUDA_VER} \
      conda-forge::blas=1.1=openblas \
      libgcc-ng=${LIB_NG_VERSION} \
      libstdcxx-ng=${LIB_NG_VERSION} \
      python=${PYTHON_VERSION} \
      #TODO: Add additional conda packages here
    && conda clean -afy \
    && sed -i 's/conda activate base/conda activate dev/g' ~/.bashrc \
    && chmod -R ugo+w /opt/conda

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
```

If you can include all of the conda dependencies in the image, building the actual project will be much faster.


# What name and tag do I use?

`gpuci/<project>-base:cuda${CUDA_VERSION}-${LINUX_VERSION}-gcc${CC_VERSION}-py${PYTHON_VERSION}`

Example: `gpuci/rapidsai-base:cuda10.1-ubuntu18.04-gcc7-py3.6`


# How can I use gcc7 in centos7 images?

Simply include this snippet in a Dockerfile.centos7 file. You can use the same template above, replacing the 'Set environment section'

```
# Install gcc7 from prebuilt image
COPY --from=gpuci/builds-gcc7:${CUDA_VERSION}-devel-centos7 /usr/local/gcc7 /usr/local/gcc7

# Update environment to use new gcc7
ENV CC=${GCC7_DIR}/bin/gcc
ENV CXX=${GCC7_DIR}/bin/g++
ENV CUDAHOSTCXX=${GCC7_DIR}/bin/g++
ENV LD_LIBRARY_PATH=${GCC7_DIR}/lib64:$CONDA_PREFIX:$LD_LIBRARY_PATH
ENV NUMBAPRO_NVVM=/usr/local/cuda/nvvm/lib64/libnvvm.so
ENV NUMBAPRO_LIBDEVICE=/usr/local/cuda/nvvm/libdevice
ENV PATH=$PATH:/conda/bin
ENV PATH=${GCC7_DIR}/bin:$PATH
```


# How do create the driver image?

You don't need to do anything! By providing a `ubuntu16.04` image following the tag scheme above, gpuCI can automatically extend your image and add the drivers.

It will create images named `gpuci/<project>-base-drivers:cuda${CUDA_VERSION}-${LINUX_VERSION}-gcc${CC_VERSION}-py${PYTHON_VERSION}`

Background: On gpuCI, CPU builds require the drivers to be force installed to the docker image. This is because there are no drivers or GPUs on the host to pass through using nvidia-docker. This is only used for Ubuntu 16.04 images.


# Do I need to build and publish the images myself?

Nope! If you can host your Dockerfile in a git repository accessible from the internet, gpuCI itself can build and publish them.

Just contact the RAPIDS Ops team to set this up.