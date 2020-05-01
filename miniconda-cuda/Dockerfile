ARG FROM_IMAGE=nvidia/cuda
ARG CUDA_VER=10.2
ARG CUDA_TYPE=devel
ARG LINUX_VER=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VER}-${CUDA_TYPE}-${LINUX_VER}

# Pull argument from build args
ARG LINUX_VER

# Define versions and download locations
ARG CONDA_VER=4.7.12
ARG TINI_VER=v0.18.0
ARG MINICONDA_URL=http://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VER}-Linux-x86_64.sh
ARG TINI_URL=https://github.com/krallin/tini/releases/download/${TINI_VER}/tini

# Set environment
ENV PATH=${PATH}:/opt/conda/bin
ENV DEBIAN_FRONTEND=noninteractive

# Update and add pkgs for Ubuntu
RUN if [ "${LINUX_VER}" != "centos7" ] ; then \
      apt-get update \
      && apt-get install -y wget bzip2 ca-certificates curl git tzdata \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* ; \
    else \
      echo -e "\n\n>>>> SKIPPING: LINUX_VER is not Ubuntu\n\n"; \
    fi

# Update and add pkgs for centOS
RUN if [ "${LINUX_VER}" == "centos7" ] ; then \
      yum -y install wget bzip2 ca-certificates curl git which \
      && yum clean all ; \
    else \
      echo -e "\n\n>>>> SKIPPING: LINUX_VER is not centOS\n\n"; \
    fi

# Install miniconda and configure
RUN wget --quiet ${MINICONDA_URL} -O /miniconda.sh \
    && /bin/bash /miniconda.sh -b -p /opt/conda \
    && rm -f /miniconda.sh \
    && echo "conda ${CONDA_VER}" >> /opt/conda/conda-meta/pinned \
    && /opt/conda/bin/conda clean -afy \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate base" >> ~/.bashrc \
    && chmod -R ugo+w /opt/conda \
    && ln -s /opt/conda /conda

# Install tini for init
RUN wget --quiet ${TINI_URL} -O /usr/bin/tini \
    && chmod +x /usr/bin/tini

## Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
