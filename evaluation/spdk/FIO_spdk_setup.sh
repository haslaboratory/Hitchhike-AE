SCRIPT_PATH=`realpath $0`
# /mnt/H5300/Hitchhike-AE/evaluation/spdk/FIO_spdk_setup.sh

BASE_DIR=`dirname $SCRIPT_PATH`
# /mnt/H5300/Hitchhike-AE/evaluation/spdk

ARTIFACT_DIR=$(realpath "$BASE_DIR/../..")
# /mnt/H5300/Hitchhike-AE

SPDK_PATH="$ARTIFACT_DIR/spdk"
# /mnt/H5300/Hitchhike-AE/spdk


# need a device param ( /dev/nvme*)
DEV_NAME=$1
DEV_ID=`basename $DEV_NAME`
printf "$DEV_ID\n"
DEV_PCI_ADDR=`cat /sys/block/$DEV_ID/device/address`
printf "$DEV_PCI_ADDR\n"
# # Unmount devic
# ···

pushd $SPDK_PATH
unset PCI_BLOCKED
export PCI_ALLOWED="$DEV_PCI_ADDR"
sudo -E ./scripts/setup.sh config
popd
