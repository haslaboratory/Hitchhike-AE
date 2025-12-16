#!/bin/bash

SCRIPT_PATH=`realpath $0`
BASE_DIR=`dirname $SCRIPT_PATH`
# printf "$BASE_DIR\n"
ARTIFACT_DIR="$BASE_DIR/.."
# printf "$ARTIFACT_DIR\n"
STORE_PATH="$BASE_DIR/../Leanstore"
LIB_PATH="$BASE_DIR/../liburing"


# install dependencies
sudo apt-get install -y cmake libtbb2-dev libaio-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev \
    librocksdb-dev liblmdb-dev libwiredtiger-dev

# build liburing
pushd $LIB_PATH
git submodule update --init --recursive
./configure --cc=gcc --cxx=g++
make -j$(nproc)
sudo make install
popd


# build Leanstore
pushd $STORE_PATH
git submodule update --init --recursive
mkdir build && cd build && cmake -DCMAKE_BUILD_TYPE=Release .. && make -j

popd