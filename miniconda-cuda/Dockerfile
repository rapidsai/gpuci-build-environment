ARG FROM_IMAGE=nvidia/cuda
ARG CUDA_VER=10.2
ARG IMAGE_TYPE=devel
ARG LINUX_VER=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}

# Pull argument from build args
ARG FULL_CUDA_VER
ARG LINUX_VER

# Define versions and download locations
ARG CONDA_VER=4.8.3
ARG TINI_VER=v0.18.0
ARG MINICONDA_URL=http://repo.anaconda.com/miniconda/Miniconda3-py38_${CONDA_VER}-Linux-x86_64.sh
ARG TINI_URL=https://github.com/krallin/tini/releases/download/${TINI_VER}/tini

# Set environment
ENV CONDA_DIR=/opt/conda
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US:en
ENV PATH=${CONDA_DIR}/bin:${PATH}
ENV DEBIAN_FRONTEND=noninteractive

# Set CUDA_VERSION as in some 'nvidia/cuda' images this is not set
## A lot of scripts and conda recipes depend on this env var
ENV CUDA_VERSION=${FULL_CUDA_VER}

# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Update and add pkgs for Ubuntu, also generate locales for 'en_US.UTF-8'
RUN if [ "${LINUX_VER:0:6}" == "ubuntu" ] ; then \
      apt-get update -q \
      && apt-get upgrade -y \
      && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bzip2 \
        ca-certificates \
        curl \
        git \
        locales \
        patch \
        tzdata \
        unzip \
        wget \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
      && locale-gen ; \
    else \
      echo -e "\n\n>>>> SKIPPING: LINUX_VER is not 'ubuntu16.04' or 'ubuntu18.04'\n\n"; \
    fi

# Disable CUDA repo using the appropriate manager to prevent cross CUDA version
# updates seen on 10.1 with 10.2 libraries
# CentOS 8 - install glibc langpack
RUN if [ "${LINUX_VER}" == "centos7" ] ; then \
      yum-config-manager --disable cuda ; \
    elif [ "${LINUX_VER}" == "centos8" ] ; then \
      dnf install -y \
        'dnf-command(config-manager)' \
        glibc-langpack-en \
      && dnf config-manager --set-disabled cuda ; \
    fi

# Update and add pkgs for CentOS
RUN if [ "${LINUX_VER:0:6}" == "centos" ] ; then \
      yum -y update \
      && yum remove -y bind-license \
      && yum -y install \
        autoconf \
        automake \
        bzip2 \
        ca-certificates \
        curl \
        git \
        make \
        patch \
        unzip \
        wget \
        which \
      && yum clean all ; \
    else \
      echo -e "\n\n>>>> SKIPPING: LINUX_VER is not 'centos7' or 'centos8'\n\n"; \
    fi

# Install miniconda and configure
RUN wget --quiet ${MINICONDA_URL} -O /miniconda.sh \
    && /bin/bash /miniconda.sh -b -p /opt/conda \
    && rm -f /miniconda.sh \
    && echo "conda ${CONDA_VER}" >> /opt/conda/conda-meta/pinned \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate base" >> ~/.bashrc \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/skel/.bashrc \
    && echo "auto_update_conda: False" >> /opt/conda/.condarc \
    && ln -s /opt/conda /conda

# Clean up conda and set permissions for all users
RUN chmod -R ugo+w /opt/conda\
    && /opt/conda/bin/conda clean -tipy \
    && chmod -R ugo+w /opt/conda

# Install tini for init
RUN wget --quiet ${TINI_URL} -O /usr/bin/tini \
    && chmod +x /usr/bin/tini

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]
