ARG CUDA_VERSION=9.2
ARG CUDA_TYPE=devel
ARG LINUX_VERSION=ubuntu16.04
ARG PYTHON_VERSION=3.6
FROM nvidia/cuda:${CUDA_VERSION}-${CUDA_TYPE}-${LINUX_VERSION}

# Define arguments
ARG PYTHON_VERSION
ARG CONDA_VERSION=4.6.14
ARG TINI_VERSION=v0.18.0
ARG MINICONDA_URL=https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh
ARG TINI_URL=https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini

# Set environment
ENV PATH=${PATH}:/conda/bin
ENV DEBIAN_FRONTEND=noninteractive

# Update and add pkgs and install conda
RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    wget --quiet ${MINICONDA_URL} -O /miniconda.sh && \
    /bin/bash /miniconda.sh -b -p /opt/conda && \
    rm -f /miniconda.sh && \
    echo "conda ${CONDA_VERSION}" >> /opt/conda/conda-meta/pinned && \
    /opt/conda/bin/conda install -y nomkl python=${PYTHON_VERSION} && \
    /opt/conda/bin/conda clean -afy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    chmod 777 -R /opt/conda && \
    ln -s /opt/conda /conda && \
    wget --quiet ${TINI_URL} -O /usr/bin/tini && \
    chmod +x /usr/bin/tini 

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
