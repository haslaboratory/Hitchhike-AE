#!/bin/bash

TARGET_IDS=(
    "nvme-DAPUSTOR_DPHV5104T0TA03T2000_HS5U00A23800DTJL"
    "nvme-MZWLO3T8HCLS-01AGG_S7BUNE0WA01304"
    "nvme-SAMSUNG_MZQL21T9HCJR-00B7C_S63SNC0T837816"
)

i=0

for id in "${TARGET_IDS[@]}"; do
    # Resolve the actual device path
    real_dev=$(readlink -f "/dev/disk/by-id/$id")
    
    # Check if the device exists
    if [ -z "$real_dev" ] || [ ! -e "$real_dev" ]; then
        echo "Error: can't find device ID: $id"
        exit 1
    fi

    mount_point="/mnt/SSD${i}"

    echo "========================================================"
    echo "Processing $i: $real_dev (ID: $id)"
    echo "Target mount point: $mount_point"
    echo "========================================================"

    # Check if the device is already mounted
    # Grep quietly in /proc/mounts
    if grep -qs "^$real_dev " /proc/mounts; then
        # Get the current mount point for notification
        current_mp=$(grep "^$real_dev " /proc/mounts | awk '{print $2}')
        
        echo "⚠️  SKIP: Device $real_dev is already mounted at [$current_mp]."
        echo "   Skipping format and testfile generation to protect existing data."
        
        # Important: Increment counter to ensure SSD0, SSD1, SSD2 indices align correctly
        i=$((i + 1))
        continue
    fi

    # File system setup steps
    echo "[1/4] Formatting $real_dev to ext4..."
    # -F forces formatting without confirmation
    sudo mkfs.ext4 -F "$real_dev"

    # Handle the mount point directory
    if [ ! -d "$mount_point" ]; then
        echo "[2/4] Creating directory $mount_point..."
        sudo mkdir -p "$mount_point"
    else
        # If the directory exists and is currently a mountpoint (e.g., used by another disk), unmount it
        if mountpoint -q "$mount_point"; then
            echo "[Check] Unmounting existing $mount_point..."
            sudo umount "$mount_point"
        fi
    fi

    echo "[3/4] Mounting $real_dev to $mount_point..."
    sudo mount "$real_dev" "$mount_point"

    # Verify mount success
    if [ $? -ne 0 ]; then
        echo "Error: Failed to mount $real_dev"
        exit 1
    fi

    echo "[4/4] Generating 100GB testfile (please wait)..."
    sudo dd if=/dev/zero of="${mount_point}/testfile" bs=1M count=102400 status=progress

    echo "Success: SSD${i} setup complete."
    
    # Increment counter for normal flow
    i=$((i + 1))
done

echo "========================================================"
echo "Completed all filesystem setups."