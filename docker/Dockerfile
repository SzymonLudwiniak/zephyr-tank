FROM ubuntu:22.04

ARG ZSDK_VERSION=0.16.5
ARG Z_RELEASE=v3.5.0

# Set default shell during Docker image build to bash
SHELL ["/bin/bash", "-c"]

# Set non-interactive frontend for apt-get to skip any user confirmations
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq -y update && \
    apt-get -qq -y upgrade && \
    apt-get -qq install --no-install-recommends -y \
    ccache \
    device-tree-compiler \
    dfu-util \
    file \
    gcc \
    gcc-multilib \
    gcovr \
    git \
    gperf \
    lcov \
    libcairo2-dev \
    libgirepository1.0-dev \
    lsb-release \
    software-properties-common \
    gnupg \
    make \
    ninja-build \
    openssh-client \
    python3-dev \
    python3-pip \
    python3-ply \
    python3-setuptools \
    python-is-python3 \
    g++-multilib \
    libsdl2-dev \
    qemu \
    cmake \
    ruby \
    wget \
    sudo \
    xz-utils \
    vim \
    thrift-compiler > /dev/null

# Install multi-lib gcc (x86 only)
RUN if [ "${HOSTTYPE}" = "x86_64" ]; then \
    apt-get -qq install --no-install-recommends -y \
    gcc-multilib \
    g++-multilib \
    ; fi

# Install i386 packages (x86 only)
RUN if [ "${HOSTTYPE}" = "x86_64" ]; then \
    dpkg --add-architecture i386 && \
    apt-get -qq -y update && \
    apt-get -qq -y upgrade && \
    apt-get -qq install --no-install-recommends -y \
    libsdl2-dev:i386 libfuse-dev:i386 \
    ; fi

# Install Python dependencies
RUN python3 -m pip install -U --no-cache-dir pip && \
    pip3 install -q -U --no-cache-dir wheel setuptools && \
    pip3 install -q --no-cache-dir pygobject && \
    pip3 install -q --no-cache-dir \
    -r https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/main/scripts/requirements.txt \
    -r https://raw.githubusercontent.com/zephyrproject-rtos/mcuboot/main/scripts/requirements.txt \
    GitPython imgtool junitparser numpy protobuf PyGithub \
    pylint sh statistics west \
    nrf-regtool && \
    pip3 check > /dev/null

# Clean up stale packages
RUN apt-get -qq clean -y && \
    apt-get -qq autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/* > /dev/null

# Install gcovr
RUN python -q -m pip install -U gcovr

# Install west
RUN python -q -m pip install -U west

# Install Zephyr
RUN west init /zephyrproject
WORKDIR /zephyrproject
RUN west update > /dev/null

# Export CMake package
RUN west zephyr-export

# Get Zephyr SDK bundle
RUN wget -q https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/zephyr-sdk-${ZSDK_VERSION}_linux-x86_64.tar.xz
# Verify download
RUN wget -q -O - https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/sha256.sum | shasum --check --ignore-missing
# Extract archive
RUN tar xf zephyr-sdk-${ZSDK_VERSION}_linux-x86_64.tar.xz

# Run the setup
RUN zephyr-sdk-${ZSDK_VERSION}/setup.sh -t all 
RUN zephyr-sdk-${ZSDK_VERSION}/setup.sh -h 
RUN zephyr-sdk-${ZSDK_VERSION}/setup.sh -c 

# Remove archive
RUN rm zephyr-sdk-${ZSDK_VERSION}_linux-x86_64.tar.xz

# Install clang-format-16
RUN wget -q https://apt.llvm.org/llvm.sh && \
    chmod +x llvm.sh && \
    ./llvm.sh 16 && \
    rm llvm.sh && \
    apt-get install -y clang-format-16

# Checkout to Zephyr release
WORKDIR /zephyrproject/zephyr
RUN git checkout tags/zephyr-${Z_RELEASE}; \
    git pull; \
    west update > /dev/null; \
    west blobs fetch hal_espressif

# Setup user as non-root
RUN useradd -d /home/non-root -m -s /bin/bash non-root
RUN chown -R non-root:non-root /zephyrproject/zephyr/

USER non-root

USER root
