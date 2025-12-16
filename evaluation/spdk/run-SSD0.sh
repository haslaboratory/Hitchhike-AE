#!/bin/bash

SCRIPT_PATH=`realpath $0`
# /mnt/H5300/Hitchhike-AE/evaluation/spdk/run.sh

BASE_DIR=`dirname $SCRIPT_PATH`
# /mnt/H5300/Hitchhike-AE/evaluation/spdk

ARTIFACT_DIR=$(realpath "$BASE_DIR/../..")
# /mnt/H5300/Hitchhike-AE

SPDK_PATH="$ARTIFACT_DIR/spdk"
# /mnt/H5300/Hitchhike-AE/spdk

mkdir -p "SSD0"
mkdir -p "threads"
mkdir -p "depth"


#1. the first nvme device (/dev/nvme*)
# Preferably, the drive should be the one with the best performance, and we recommend the Dapustor H5300 (Pcie 5.0 2800K IOPS).
TEST_DEVS=/dev/nvme3n1
# get device ID and PCI address
DEV_ID=`basename $TEST_DEVS`
printf "$DEV_ID\n"
PCI_ADDR=`cat /sys/block/$DEV_ID/device/address`
printf "PCI ADDR1: $PCI_ADDR\n"
PCI_ADDR=${PCI_ADDR//:/\.}
printf "PCI ADDR2: $PCI_ADDR\n"


sudo ./FIO_spdk_setup.sh $TEST_DEVS


# spdk test, you need to change the traddr according to your device PCI address (e.g., trtype=PCIe traddr=0000.46.00.0 ns=1)
for threads in 1
do
    sudo env LD_PRELOAD=$ARTIFACT_DIR/spdk/build/fio/spdk_nvme $ARTIFACT_DIR/FIO/fio \
    --name=test --ioengine=spdk --group_reporting=1 --direct=1 --time_based=1 --ramp_time=10 --runtime=30 --iodepth=512 \
    --rw=randread --numjobs=$threads --thread=1 --bs=4k --filename="trtype=PCIe traddr=$PCI_ADDR ns=1" > SSD0/spdk.log
done


for threads in 1 2 3 4 5 6 7 8
do
    sudo  env env LD_PRELOAD=$ARTIFACT_DIR/spdk/build/fio/spdk_nvme $ARTIFACT_DIR/FIO/fio \
    --name=test --ioengine=spdk --group_reporting=1 --direct=1 --time_based=1 --ramp_time=10 --runtime=30 --iodepth=512 \
    --rw=randread --numjobs=$threads --thread=1 --bs=4k --filename="trtype=PCIe traddr=$PCI_ADDR ns=1" > threads/fio_spdk_T${threads}.log
done

declare -a iodepth=("1" "4" "8" "16" "32" "64" "128" "256" "512" "1024")
    for ((i=0; i< ${#iodepth[@]}; i++)); do
        depth="${iodepth[i]}"
        sudo env LD_PRELOAD=$ARTIFACT_DIR/spdk/build/fio/spdk_nvme $ARTIFACT_DIR/FIO/fio \
        --name=test --ioengine=spdk --group_reporting=1 --direct=1 --time_based=1 --ramp_time=10 --runtime=30 --iodepth=$depth \
        --rw=randread --numjobs=1 --thread=1 --bs=4k --filename="trtype=PCIe traddr=$PCI_ADDR ns=1" > depth/fio_spdk_D${depth}.log
done

sudo ./FIO_spdk_reset.sh