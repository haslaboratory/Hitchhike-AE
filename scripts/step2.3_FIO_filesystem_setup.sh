#!/bin/bash

# ----------It is necessary to manually select the hard disk and mount point.-------
# ----------It is necessary to manually select the hard disk and mount point.-------
# ----------It is necessary to manually select the hard disk and mount point.-------

# ----For our test devices-----:
# Dapustor H5300  HS5U00A23800DTKA
# sudo nvme format /dev/nvme3n1
sudo mkfs.ext4 /dev/nvme3n1
sudo mount /dev/nvme3n1 /mnt/SSD0
dd if=/dev/zero of=/mnt/SSD0/testfile bs=1M count=102400 status=progress



# Sumsang PM1743 SSD SAMSUNG MZQL21T9HCJR-00B7C
# sudo nvme format /dev/nvme5n1
sudo mkfs.ext4 /dev/nvme5n1
sudo mount /dev/nvme5n1 /mnt/SSD1
dd if=/dev/zero of=/mnt/SSD1/testfile bs=1M count=102400 status=progress

# Sumsang PM9A3 SSD SAMSUNG MZQL21T9HCJR-00B7C
# sudo nvme format /dev/nvme6n1
sudo mkfs.ext4 /dev/nvme6n1
sudo mount /dev/nvme6n1 /mnt/SSD2
dd if=/dev/zero of=/mnt/SSD2/testfile bs=1M count=102400 status=progress
