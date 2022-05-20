ARG FROM_IMAGE=nvidia/cuda
ARG CUDA_VER=10.2
ARG IMAGE_TYPE=devel
ARG LINUX_VER=ubuntu18.04
FROM ${FROM_IMAGE}:${CUDA_VER}-${IMAGE_TYPE}-${LINUX_VER}

# Pull argument from build args
ARG FULL_CUDA_VER
ARG LINUX_VER

# Define versions and download locations
ARG ARCH_TYPE=x86_64
ARG CONDA_VER=4.12.0-0
ARG MINIFORGE_URL=https://github.com/conda-forge/miniforge/releases/download/${CONDA_VER}/Miniforge3-${CONDA_VER}-Linux-${ARCH_TYPE}.sh

# Set environment
ENV PATH=/opt/conda/bin:${PATH}
ENV DEBIAN_FRONTEND=noninteractive

# Set CUDA_VERSION as in some 'nvidia/cuda' images this is not set
## A lot of scripts and conda recipes depend on this env var
ENV CUDA_VERSION=${FULL_CUDA_VER}

# Enables "source activate conda"
SHELL ["/bin/bash", "-c"]

# Update and add pkgs for Ubuntu, also generate locales for 'en_US.UTF-8'
RUN if [ "${LINUX_VER:0:6}" == "ubuntu" ] ; then \
      apt-key adv --fetch-keys "https://developer.download.nvidia.com/compute/cuda/repos/${LINUX_VER/./}/${ARCH_TYPE}/3bf863cc.pub" \
      && apt-get update \
      && apt-get upgrade -y \
      && apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bzip2 \
        ca-certificates \
        curl \
        git \
        locales \
        libnuma1 \
        libnuma-dev \
        patch \
        tzdata \
        unzip \
        wget \
      && apt-get clean \
      && rm -rf /var/lib/apt/lists/* \
      && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
      && locale-gen ; \
    else \
      echo -e "\n\n>>>> SKIPPING: LINUX_VER is not 'ubuntu'\n\n"; \
    fi

# Disable CUDA repo using the appropriate manager to prevent cross CUDA version
# updates seen on 10.1 with 10.2 libraries
# CentOS 8 - install glibc langpack
RUN if [ "${LINUX_VER}" == "centos7" ] ; then \
      yum-config-manager --disable cuda ; \
    elif [ "${LINUX_VER}" == "centos8" ] ; then \
      sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-* \
      && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-* ; \
      dnf install -y \
        'dnf-command(config-manager)' \
        glibc-langpack-en \
      && dnf config-manager --set-disabled cuda ; \
    fi

# Update and add pkgs for CentOS
RUN if [ "${LINUX_VER:0:6}" == "centos" ] ; then \
      yum -y update \
      && yum remove -y bind-license \
      && yum -y install --setopt=install_weak_deps=False \
        autoconf \
        automake \
        bzip2 \
        ca-certificates \
        curl \
        git \
        make \
        numactl-devel \
        numactl-libs \
        patch \
        unzip \
        wget \
        which \
      && yum clean all ; \
    else \
      echo -e "\n\n>>>> SKIPPING: LINUX_VER is not 'centos7' or 'centos8'\n\n"; \
    fi

# Install miniforge and configure
RUN wget --quiet ${MINIFORGE_URL} -O /miniforge.sh \
    && /bin/bash /miniforge.sh -b -p /opt/conda \
    && rm -f /miniforge.sh \
    && ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate base" >> ~/.bashrc \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/skel/.bashrc \
    && echo "auto_update_conda: False" >> /opt/conda/.condarc \
    && echo "ssl_verify: False" >> /opt/conda/.condarc \
    && ln -s /opt/conda /conda

# Install tini for init
RUN conda install -k -y tini \
    || conda install -k -y tini

# Clean up conda and set permissions for all users
RUN chmod -R ugo+w /opt/conda \
    && /opt/conda/bin/conda clean -tipy \
    && chmod -R ugo+w /opt/conda

ENTRYPOINT [ "/opt/conda/bin/tini", "--" ]
CMD [ "/bin/bash" ]
