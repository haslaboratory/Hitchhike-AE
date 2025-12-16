#!/bin/bash

SCRIPT_PATH=`realpath $0`
# /mnt/H5300/Hitchhike-AE/evaluation/spdk/run.sh

BASE_DIR=`dirname $SCRIPT_PATH`
# /mnt/H5300/Hitchhike-AE/evaluation/spdk

ARTIFACT_DIR=$(realpath "$BASE_DIR/../..")
# /mnt/H5300/Hitchhike-AE

SPDK_PATH="$ARTIFACT_DIR/spdk"
# /mnt/H5300/Hitchhike-AE/spdk

mkdir -p "SSD2"

#1. the third nvme device (/dev/nvme*), we recommend the Samsung PM9A3 (PCIe 4.0 900K IOPS).
TEST_DEVS=/dev/nvme0n1

# get device ID and PCI address
DEV_ID=`basename $TEST_DEVS`
printf "$DEV_ID\n"
PCI_ADDR=`cat /sys/block/$DEV_ID/device/address`
printf "PCI ADDR1: $PCI_ADDR\n"
PCI_ADDR=${PCI_ADDR//:/\.}
printf "PCI ADDR2: $PCI_ADDR\n"


sudo ./FIO_spdk_setup.sh $TEST_DEVS

for threads in 1
do
    sudo env LD_PRELOAD=$ARTIFACT_DIR/spdk/build/fio/spdk_nvme $ARTIFACT_DIR/FIO/fio \
    --name=test --ioengine=spdk --group_reporting=1 --direct=1 --time_based=1 --ramp_time=10 --runtime=30 --iodepth=512 \
    --rw=randread --numjobs=$threads --thread=1 --bs=4k --filename="trtype=PCIe traddr=$PCI_ADDR ns=1" >> SSD2/spdk.log
done

sudo ./FIO_spdk_reset.sh