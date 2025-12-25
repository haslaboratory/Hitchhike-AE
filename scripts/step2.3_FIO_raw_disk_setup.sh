#!/bin/bash

# you shuld format the nvme device for raw disk testing
# sudo nvme format /dev/<nvme*n1> --force
TARGET_IDS=(
    "nvme-DAPUSTOR_DPHV5104T0TA03T2000_HS5U00A23800DTJL"
    "nvme-MZWLO3T8HCLS-01AGG_S7BUNE0WA01304"
    "nvme-SAMSUNG_MZQL21T9HCJR-00B7C_S63SNC0T837816"
)

for id in "${TARGET_IDS[@]}"; do
    real_dev=$(readlink -f "/dev/disk/by-id/$id")
    if [ -z "$real_dev" ] || [ ! -e "$real_dev" ]; then
        echo "Error: can't find device ID: $id"
        exit 1
    fi

    echo "Formatting device $real_dev ..."
    sudo nvme format "$real_dev" --force
done