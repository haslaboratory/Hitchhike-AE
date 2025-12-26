#!/bin/bash

TARGET_IDS=(
    "nvme-DAPUSTOR_DPHV5104T0TA03T2000_HS5U00A23800DTJL"
    "nvme-MZWLO3T8HCLS-01AGG_S7BUNE0WA01304"
    "nvme-SAMSUNG_MZQL21T9HCJR-00B7C_S63SNC0T837816"
)

for id in "${TARGET_IDS[@]}"; do
    # Resolve the actual device path
    real_dev=$(readlink -f "/dev/disk/by-id/$id")
    
    # Check if the device exists
    if [ -z "$real_dev" ] || [ ! -e "$real_dev" ]; then
        echo "Error: can't find device ID: $id"
        exit 1
    fi

    # Check if the device is mounted
    if lsblk -n -o MOUNTPOINT "$real_dev" | grep -q "."; then
        mount_point=$(lsblk -n -o MOUNTPOINT "$real_dev" | grep "." | head -n 1)
        
        echo "--------------------------------------------------------"
        echo "⚠️  WARNING: Device $real_dev is currently mounted at [$mount_point]."
        echo "   Skipping format to prevent data loss."
        echo ""
        echo "   If you intend to format this device, please unmount it first:"
        echo "   $> sudo umount $mount_point"
        echo "--------------------------------------------------------"
        continue
    fi

    echo "Processing device $real_dev ..."

    # [New Step] Wipe filesystem signatures BEFORE formatting
    # This prevents blkid from detecting old filesystems due to caching
    echo "   [1/2] Wiping old filesystem signatures..."
    sudo wipefs -a "$real_dev" --force

    echo "   [2/2] Performing NVMe format..."
    sudo nvme format "$real_dev" --force
    
    # Optional: Force kernel to re-read partition table/device state
    sudo partprobe "$real_dev" 2>/dev/null

    echo "Format complete for $real_dev."
done