#!/bin/bash

TARGET_IDS=(
    "nvme-DAPUSTOR_DPHV5104T0TA03T2000_HS5U00A23800DTJL"
    "nvme-MZWLO3T8HCLS-01AGG_S7BUNE0WA01304"
    "nvme-SAMSUNG_MZQL21T9HCJR-00B7C_S63SNC0T837816"
)

i=0

for id in "${TARGET_IDS[@]}"; do
    real_dev=$(readlink -f "/dev/disk/by-id/$id")
    if [ -z "$real_dev" ] || [ ! -e "$real_dev" ]; then
        echo "Error: can't find device ID: $id"
        exit 1
    fi
    mount_point="/mnt/SSD${i}"

    echo "========================================================"
    echo "processiong $i: $real_dev (ID: $id)"
    echo "mount point: $mount_point"
    echo "========================================================"

    # file system setup steps
    echo "[1/4] Formatting $real_dev to ext4..."
    sudo mkfs.ext4 -F "$real_dev"

    if [ ! -d "$mount_point" ]; then
        echo "[2/4] Creating directory $mount_point..."
        sudo mkdir -p "$mount_point"
    else
        if mountpoint -q "$mount_point"; then
            echo "[Check] Unmounting existing $mount_point..."
            sudo umount "$mount_point"
        fi
    fi

    echo "[3/4] Mounting $real_dev to $mount_point..."
    sudo mount "$real_dev" "$mount_point"

    echo "[4/4] Generating 100GB testfile (please wait)..."
    sudo dd if=/dev/zero of="${mount_point}/testfile" bs=1M count=102400 status=progress

    echo "Success: SSD${i} is ready."
    
    i=$((i + 1))
done

echo "completed all filesystem setups."