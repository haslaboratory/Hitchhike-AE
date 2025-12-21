

# Artifact Evaluation: Hitchhike (ASPLOS '26)

This repository contains the source code, scripts, and instructions to reproduce the key results presented in the paper **"Hitchhike: Efficient Request Submission via Deferred Enforcement of Address Contiguity"** (to appear in ASPLOS '26).

## 1. System Requirements & Hardware

**Hitchhike** requires specific hardware features (NVMe SSDs) and software configurations.

*   **Storage**: NVMe SSDs (Evaluation includes PCIe 4.0, and 5.0).
*   **OS**: Ubuntu 22.04 LTS.
*   **CPU**: Evaluation environment uses 32 physical cores.

> ⚠️ **Note**: You need to adjust disk paths in the scripts. NVMe device paths (e.g., /dev/nvme0n1) may change after a server reboot. Before running any tests, please use nvme list to verify the target device by matching the Serial Number (SN) and Model. The information about the SSD devices used in this paper is as follows:

SSD0 (Dapustor H5300): HS5U00A23800DTJL (Model: DAPUSTOR DPHV5104T0TA03T2000)  
SSD1 (Samsung PM1743): S7BUNE0WA01304 (Model: MZWLO3T8HCLS-01AGG)  
SSD2 (Samsung PM9A3): S63SNC0T837816 (Model: SAMSUNG MZQL21T9HCJR-00B7C)  


### Access for Reviewers
We can provide SSH access to a host machine equipped with the required SSDs. However, as the server is located on the campus intranet, access to it requires using OpenVPN. If you need this access, please contact us via HotCRP.

## 2. Repository Components

This project consists of five major components:

*   **Linux**: A modified Linux kernel (v6.5) with Hitchhike syscall and driver support.
*   **SPDK**: The standard Storage Performance Development Kit.
*   **FIO**: An adapted version of FIO for testing Hitchhike (Raw Block & Filesystem).
*   **Blaze**: A modified graph processing library utilizing Hitchhike.
*   **LeanStore**: An asynchronous B-tree storage engine for the YCSB benchmark.
*   **Liburing**: The io_uring library.

---

## 3. Kernel Configuration
**⚠️Note: If you are using our server, you can skip this step, as the Linux 6.5-hitchhike kernel has already been installed on it.**

### Step 1: Clone the Repository
Ensure you have sufficient disk space for the kernel compilation.
**Important**: Use `--recursive` to download all submodules.

```bash
git clone --recursive https://github.com/haslaboratory/Hitchhike-AE.git
cd Hitchhike-AE
```

### Step 2: Build and Install the Kernel
We provide a script to compile the custom kernel (based on Linux 6.5).
*Note: This step involves a full kernel compilation and may take significant time (15-30 mins).*

```bash
cd scripts
sudo ./step1_build_and_install_kernel.sh
```

### Step 3: Reboot into Hitchhike Kernel
After installation, reboot the machine and select the **Linux 6.5.0-hitchhike+** kernel.

**Option A: One-time boot (Recommended)**
```bash
sudo grub-reboot "Advanced options for Ubuntu>Ubuntu, with Linux 6.5.0-hitchhike+"
sudo reboot
```

**Option B: Manual Selection**
(If the above fails, update GRUB manually):
```bash
# Check menu entry names
grep 'menuentry' /boot/grub/grub.cfg
# Edit GRUB_DEFAULT in /etc/default/grub:
sudo vim /etc/default/grub
sudo update-grub
sudo reboot
```

> **Verify Kernel**: After rebooting, run `uname -r`. It should show `6.5.0-hitchhike+`.

---

## 4. Evaluation: FIO (Figures 8-11)

This section reproduces the microbenchmark results.
> ⚠️ **Warning**: In the FIO tests, three NVMe drives were used for some of the test cases. In the tests presented in our paper, SSD0 is the Dapustor H5300 PCIe 5.0; SSD1 is the Samsung PM1743 PCIe 5.0; and SSD2 is the Samsung PM9A3 PCIe 4.0.
While the use of the exact SSD models listed above is not mandatory, it is recommended to use at least one PCIe 5.0 SSD with over 2,500K IOPS to fully leverage the advantages of Hitchhike.



### 4.1 Build FIO & SPDK
```bash
cd Hitchhike-AE/scripts
./step2_build_and_install_fio.sh
./step2.1_build_and_install_spdk.sh
```
> ⚠️ **Warning**: This will format the disk and erase all data on the target NVMe drive.

```bash
# Edit this script to define your target disk (e.g., /dev/nvme0n1)
./step2.2_FIO_raw_disk_setup.sh
```

### 4.2 Configuration (Crucial)
Before running any `run.sh` scripts, you **must manually configure** the target device paths. 
Open the script (e.g., `vim run.sh`) and search for `TEST_DEVS`, `TEST_DEVS_CMD`, or `TEST_FILES`.

**Example Configuration:**
```bash
TEST_DEVS="/dev/nvme0n1"        # For raw disk tests
TEST_DEVS_CMD="/dev/ng0n1"      # For Passthru tests (ensure it is the char device /dev/ngXnY)
TEST_FILES="/mnt/SSD0/testfile" # For Filesystem tests
```

### 4.3 Part A: Run SPDK Tests
These scripts bind devices to the SPDK driver. Since SPDK requires exclusive access to the device, we need to test SPDK first. The data from this part will be used together with the io_uring/libaio data to generate test images later.
```bash
cd ../evaluation/spdk
# Edit this script to define your target disk (e.g., /dev/nvme0n1)
./run_SSD0.sh 
# Three SSDs are used by default. You may skip this step if no additional SSD devices are available. 
./run_SSD1.sh 
./run_SSD2.sh 
```

### 4.4 Part B: Run Standard FIO (Raw Disk)
**Reproduces Figures 8, 9, 10 (a-d).**

```bash
# You can enter the folders with the corresponding numbers in sequence,  and navigate to the directory figure<N>/<N><x> (e.g., figure8/8a) to run the specific test..
cd ../figure<N>/<N><x>
# ⚠️Edit this script to define your target disk (e.g., /dev/nvme0n1)
sudo ./run.sh
```

### 4.5 Part C: Run Standard FIO (Filesystem)
**Reproduces Figure 11 (a-d).**
> ⚠️ **Warning**: This script is used to initialize the file system and mount directories. Please note to modify the corresponding file directories.
```bash
cd Hitchhike-AE/scripts
# Edit this script to define your target disk (e.g., /dev/nvme0n1) and file directories
sudo ./step2.3_FIO_filesystem_setup.sh
```
```bash
cd ../evaluation/figure11/11<x>
# Edit this script to define your target file (e.g., /mnt/SSD0/testfile)
sudo ./run.sh
```

---

## 5. Evaluation: LeanStore (Figure 14)
> ⚠️ **Warning**: Only one SSD is required for the Leanstore test. We recommend using a PCIe 5.0 SSD.
Compile and run the LeanStore benchmark (YCSB). If compilation errors occur, the issue may lie with the g++ compiler version. You can switch to G++ 11.

```bash
cd Hitchhike-AE/scripts
./step3_build_and_install_leanstore.sh
# Edit this script to define your target disk (e.g., /dev/nvme0n1)
cd ../evaluation/figure14
# 
./run_ycsb.sh
```

---

## 6. Evaluation: Blaze (Figure 13)

### 6.1 Install Dependencies (GCC-7)
Blaze requires `g++-7`. Please install it and switch the default compiler:

```bash
sudo apt update
sudo apt install -y g++-7
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 100
sudo update-alternatives --config g++
# Verify version (should be 7.x)
g++ --version
```

### 6.2 Download Datasets
> ⚠️ **Warning**: Only one SSD is required for the Blaze test. We recommend using a PCIe 5.0 SSD, and the dataset needs to be downloaded to the mount directory of this SSD.

Download and unzip the required graph datasets.
*Note: Some datasets are large (e.g., rmat30 is 102GB). For a quick verification, you may start with smaller datasets like `sk2005` or `twitter`.*

```bash
# Example: Download and unzip Twitter dataset
wget https://storage.googleapis.com/nvsl-aepdata/graphdata/sc22/twitter.zip
unzip -j twitter.zip -d /path/to/dataset/
```
*   **rmat27** (13GB): [Link](https://storage.googleapis.com/nvsl-aepdata/graphdata/sc22/rmat27.zip)
*   **rmat30** (102GB): [Link](https://storage.googleapis.com/nvsl-aepdata/graphdata/sc22/rmat30.zip)
*   **uran27** (16GB): [Link](https://storage.googleapis.com/nvsl-aepdata/graphdata/sc22/uran27.zip)
*   **twitter** (8.5GB): [Link](https://storage.googleapis.com/nvsl-aepdata/graphdata/sc22/twitter.zip)
*   **sk2005** (2.3GB): [Link](https://storage.googleapis.com/nvsl-aepdata/graphdata/sc22/sk2005.zip)
*   **friendster** (13GB): [Link](https://storage.googleapis.com/nvsl-aepdata/graphdata/sc22/friendster.zip)

### 6.3 Build and Run
> ⚠️ **Warning**: Due to certain unknown device firmware issues, Blaze may encounter problems when running on the H5300. Please execute it on the PM1743 (SSD1, PCIe5.0) instead.

```bash
cd Hitchhike-AE/scripts
./step4_build_and_install_blaze.sh

# Update dataset paths in run.sh before executing
./run.sh
```

---

## Claims and Key Results

Our modified Linux kernel implements the following contributions:
*   A new system call optimized for `io_uring` and `libaio`.
*   I/O request resubmission logic across the syscall interface, file system, block layer, and NVMe driver.
*   Integration support for FIO, LeanStore, and Blaze.

**Key Figures Reproduced:**
*   **Microbenchmarks**: Figures 8, 9, 10, 11 (FIO)
*   **Applications**: Figure 13 (Blaze), Figure 14 (LeanStore)
