ARG CUDA_VERSION=9.2
ARG CUDA_SHORT_VERSION=${CUDA_VERSION}
ARG LINUX_VERSION=ubuntu16.04
FROM nvidia/cuda:${CUDA_VERSION}-devel-${LINUX_VERSION}

# Define arguments
ARG CC_VERSION=5
ARG CXX_VERSION=5
ARG PYTHON_VERSION=3.6
ARG TINI_VERSION=v0.18.0
ARG CONDA_VERSION=4.6.14
ARG CONDA_BUILD_VERSION=3.17.8
ARG CONDA_VERIFY_VERSION=3.1.1
ARG MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh

# Set environment
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/lib64:/usr/local/lib
ENV CC=/usr/bin/gcc-${CC_VERSION}
ENV CXX=/usr/bin/g++-${CXX_VERSION}
ENV CUDAHOSTCXX=/usr/bin/g++-${CXX_VERSION}
ENV PATH=${PATH}:/conda/bin
ENV DEBIAN_FRONTEND=noninteractive

# Update and add pkgs
RUN apt-get update -y --fix-missing && \
    apt-get upgrade -y && \
    apt-get -qq install apt-utils -y --no-install-recommends && \
    apt-get install -y \
      curl \
      git \
      screen \
      gcc-${CC_VERSION} \
      g++-${CXX_VERSION} \
      wget \
      vim \
    && rm -rf /var/lib/apt/lists/*

# Install conda
RUN curl ${MINICONDA_URL} -o /miniconda.sh && \
    sh /miniconda.sh -b -p /conda && \
    rm -f /miniconda.sh && \
    echo "conda ${CONDA_VERSION}" >> /conda/conda-meta/pinned && \
    conda clean -a && \
    chmod 777 -R /conda

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
