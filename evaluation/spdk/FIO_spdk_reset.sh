#!/bin/bash

SCRIPT_PATH=`realpath $0`
# /mnt/H5300/Hitchhike-AE/evaluation/spdk/FIO_spdk_reset.sh

BASE_DIR=`dirname $SCRIPT_PATH`
# /mnt/H5300/Hitchhike-AE/evaluation/spdk

ARTIFACT_DIR=$(realpath "$BASE_DIR/../..")
# /mnt/H5300/Hitchhike-AE

SPDK_PATH="$ARTIFACT_DIR/spdk"
# /mnt/H5300/Hitchhike-AE/spdk


pushd $SPDK_PATH
unset PCI_ALLOWED
unset PCI_BLOCKED
sudo -E ./scripts/setup.sh reset
popd
