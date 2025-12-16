#!/bin/bash

SCRIPT_PATH=`realpath $0`
BASE_DIR=`dirname $SCRIPT_PATH`
ARTIFACT_DIR="$BASE_DIR/.."
BLAZE_PATH="$BASE_DIR/../Blaze"


# install dependencies
printf "Installing dependencies...\n"
sudo apt install -y build-essential cmake git libboost-dev sysstat psmisc vim  python3-pip python3 google-perftools libnuma-dev
pip3 install pandas 
sudo ln -s /usr/lib/x86_64-linux-gnu/libtcmalloc.so.4 /usr/lib/x86_64-linux-gnu/libtcmalloc.so


# build
pushd $BLAZE_PATH
git submodule update --init --recursive
mkdir -p build && cd build
cmake -DCMAKE_BUILD_TYPE=Release .. && make -j $(nproc)
popd