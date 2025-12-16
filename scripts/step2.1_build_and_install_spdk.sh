#!/bin/bash

SCRIPT_PATH=`realpath $0`
BASE_DIR=`dirname $SCRIPT_PATH`
# printf "$BASE_DIR\n"
ARTIFACT_DIR="$BASE_DIR/.."
# printf "$ARTIFACT_DIR\n"
SPDK_PATH="$BASE_DIR/../spdk"
# printf "$SPDK_PATH\n"


# build
pushd $SPDK_PATH
# if [ ! -e "Makefile" ]; then
git submodule update --init --recursive
# fi

./scripts/pkgdep.sh
# build with FIO : --with-fio=/path/to/fio/repo <other configuration options>
./configure --with-fio=$ARTIFACT_DIR/FIO
make -j $(nproc)
popd