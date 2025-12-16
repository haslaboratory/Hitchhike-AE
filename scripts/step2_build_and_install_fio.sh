#!/bin/bash

SCRIPT_PATH=`realpath $0`
BASE_DIR=`dirname $SCRIPT_PATH`
ARTIFACT_DIR="$BASE_DIR/.."
FIO_PATH="$BASE_DIR/../FIO"


# build
pushd $FIO_PATH
if [ ! -e "Makefile" ]; then
    git submodule init
    git submodule update
fi

./configure
make -j $(nproc)
make install
popd

printf "Hitchhike-FIO is installed\n"
printf "Next, it is necessary to test raw disk, SPDK, and file IO in sequence.\n"