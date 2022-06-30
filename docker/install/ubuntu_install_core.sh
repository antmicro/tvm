#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

set -e
set -u
# Used for debugging RVM build
set -x
set -o pipefail

# install libraries for building c++ core on ubuntu
export DEBIAN_FRONTEND=noninteractive  # avoid tzdata interactive config.
apt-get update && apt-install-and-clear -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    curl \
    dirmngr \
    g++ \
    gdb \
    git \
    gpg \
    gpg-agent \
    graphviz \
    libcurl4-openssl-dev \
    libopenblas-dev \
    libssl-dev \
    libtinfo-dev \
    libz-dev \
    lsb-core \
    make \
    ninja-build \
    parallel \
    pkg-config \
    software-properties-common \
    sudo \
    unzip \
    wget \

wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc | gpg --dearmor - | sudo tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
os_release=$(lsb_release -sc)
echo "deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ ${os_release} main" | sudo tee /etc/apt/sources.list.d/kitware.list >/dev/null

# NOTE: to determine the package versions available, go to the Packages manifest
# e.g. https://apt.kitware.com/ubuntu/dists/${os_release}/main/binary-${arch}/Packages
# (substitute the vars) and find the oldest cmake version supported.
arch=$(dpkg-architecture -q DEB_HOST_ARCH)
case "${arch}-${os_release}" in
    amd64-bionic|i386-bionic)
        cmake_version=3.16.1-0kitware1
        ;;
    amd64-focal|i386-focal)
        cmake_version=3.17.2-0kitware1ubuntu20.04.1
        ;;
    arm64-bionic)
        cmake_version=3.21.0-0kitware1ubuntu18.04.1
        ;;
    arm64-focal)
        cmake_version=3.19.0-0kitware1ubuntu20.04.1
        ;;
    *)
        echo "Don't know which version of cmake to install for dpkg-architecture -q DEB_HOST_ARCH ${arch} and lsb_release -sc: ${os_release}"
        exit 2
        ;;
esac

apt-get update && apt-install-and-clear -y --no-install-recommends \
    cmake=${cmake_version} \
    cmake-data=${cmake_version} \
