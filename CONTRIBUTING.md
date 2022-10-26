# Contributing to gpuci-build-environment

If you are interested in contributing to gpuci-build-environment, your contributions will fall
into three categories:
1. You want to report a bug, feature request, or documentation issue
    - File an [issue](https://github.com/rapidsai/gpuci-build-environment/issues/new)
    describing what you encountered or what you want to see changed.
    - The RAPIDS team will evaluate the issues and triage them, scheduling
    them for a release. If you believe the issue needs priority attention
    comment on the issue to notify the team.
2. You want to propose a new Feature and implement it
    - Post about your intended feature, and we shall discuss the design and
    implementation.
    - Once we agree that the plan looks good, go ahead and implement it, using
    the [code contributions](#code-contributions) guide below.
3. You want to implement a feature or bug-fix for an outstanding issue
    - Follow the [code contributions](#code-contributions) guide below.
    - If you need more context on a particular issue, please ask and we shall
    provide.

## Code contributions

### Your first issue

1. Read the project's [README.md](https://github.com/rapidsai/gpuci-build-environment/blob/main/README.md)
    to learn how to setup the development environment
2. Find an issue to work on. The best way is to look for the [good first issue](https://github.com/rapidsai/gpuci-build-environment/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22)
    or [help wanted](https://github.com/rapidsai/gpuci-build-environment/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) labels
3. Comment on the issue saying you are going to work on it
4. Code! Make sure to update unit tests!
5. When done, [create your pull request](https://github.com/rapidsai/gpuci-build-environment/compare)
6. Verify that CI passes all [status checks](https://help.github.com/articles/about-status-checks/). Fix if needed
7. Wait for other developers to review your code and update code as needed
8. Once reviewed and approved, a RAPIDS developer will merge your pull request

Remember, if you are unsure about anything, don't hesitate to comment on issues
and ask for clarifications!

### Attribution
Portions adopted from https://github.com/pytorch/pytorch/blob/master/CONTRIBUTING.md

# Development and Repo Details

## Folder Structure

Root folders in this repo correspond to the image name hosted on
[Docker Hub](https://hub.docker.com/u/gpuci). These should be descriptive for
the image or matching the name of the GH organization that uses the image for
gpuCI.

There is one current exception `/legacy` which hosts legacy images.

## Extending Images

### How can I create images to build my project on gpuCI?

gpuCI can use any docker images to build your project. However, the RAPIDS Ops team has some prebuilt parent images which make things easier especially if you depend on CUDA and Conda.

See [Public Images](README.md#public-images) for list of options for `FROM`-ing

Here is an example on extending the image:

```Dockerfile
ARG FROM_IMAGE=gpuci/miniforge-cuda
ARG CUDA_VERSION=10.1
ARG CUDA_VER=${CUDA_VERSION}
ARG CUDA_TYPE=devel
ARG LINUX_VERSION=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VERSION}-${CUDA_TYPE}-${LINUX_VERSION}

# Define arguments
ARG CUDA_VER
ARG PYTHON_VERSION=3.7
ARG LIB_NG_VERSION=7.5.0

# Set environment
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV PATH=${PATH}:/conda/bin

# Create a dev conda env
RUN source activate base \
    && conda create --no-default-packages --override-channels -n dev \
      -c conda-forge \
      -c nvidia \
      cudatoolkit=${CUDA_VER} \
      conda-forge::blas \
      python=${PYTHON_VERSION} \
      #TODO: Add additional conda packages here
    && conda clean -afy \
    && sed -i 's/conda activate base/conda activate dev/g' ~/.bashrc \
    && chmod -R ugo+w /opt/conda

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/opt/conda/bin/tini", "--" ]
CMD [ "/bin/bash" ]
```

If you can include all of the conda dependencies in the image, building the actual project will be much faster.


### What name and tag do I use?

`gpuci/<project>:${PROJECT_VERSION}-cuda${CUDA_VERSION}-devel-${LINUX_VERSION}-py${PYTHON_VERSION}`

Example: `gpuci/rapidsai:0.15-cuda10.1-devel-ubuntu18.04-py3.6`


### How do create the driver image?

You don't need to do anything! By providing a `ubuntu16.04` image following the tag scheme above, gpuCI can automatically extend your image and add the drivers.

It will create images named `gpuci/<project>-drivers:${PROJECT_VERSION}-cuda${CUDA_VERSION}-devel-${LINUX_VERSION}-py${PYTHON_VERSION}`

Background: On gpuCI, CPU builds require the drivers to be force installed to the docker image. This is because there are no drivers or GPUs on the host to pass through using nvidia-docker. This is only used for Ubuntu 16.04 images.


### Do I need to build and publish the images myself?

Nope! If you can host your Dockerfile in a git repository accessible from the internet, gpuCI itself can build and publish them.

Just contact the RAPIDS Ops team to set this up.

## gpuCI Integration

More information to come...
