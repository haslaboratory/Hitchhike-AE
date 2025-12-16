#!/bin/bash
set -eux -o pipefail

# # Enable source
printf "Installing dependencies...\n"
sudo cp /etc/apt/sources.list /etc/apt/sources.list~
sudo sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
sudo apt-get update

# # Install build dependencies
sudo apt-get build-dep linux linux-image-$(uname -r) -y || true
sudo apt-get install -y libncurses-dev flex bison openssl libssl-dev dkms \
    libelf-dev libudev-dev libpci-dev libiberty-dev \
    autoconf fakeroot bc cpio debhelper


SCRIPT_PATH=`realpath $0`
BASE_DIR=`dirname $SCRIPT_PATH`
ARTIFACT_DIR="$BASE_DIR/.."
LINUX_PATH="$BASE_DIR/../Linux"

pushd $LINUX_PATH
if [ ! -e "Makefile" ]; then
    git submodule init
    git submodule update
fi

# Cleanup the previous build
rm -f ../linux-* 2> /dev/null
make distclean

# Configure kernel
printf "Configuring kernel...\n"
(yes "" || true) | make localmodconfig
./scripts/config -e CONFIG_UIO
./scripts/config -e CONFIG_UIO_PCI_GENERIC

# Need kernel headers through /sys/kernel/kheaders.tar.xz
./scripts/config -e CONFIG_IKHEADERS
./scripts/config -e CONFIG_KPROBES

# Disable kernel module signature verification
./scripts/config -d SYSTEM_REVOCATION_KEYS
./scripts/config -d MODULE_SIG
./scripts/config -d MODULE_SIG_ALL

make olddefconfig

if [ -z "$(cat .config | grep CONFIG_UIO_PCI_GENERIC)" ]; then
    printf "Cannot find CONFIG_UIO_PCI_GENERIC in .config file. Please enable it manually by 'make nconfig'.\n"
    exit 1
fi

# Compile kernel
printf "Compiling kernel...\n"
make deb-pkg -j $(nproc)
popd

# Install kernel
printf "Installing kernel...\n"
pushd $ARTIFACT_DIR
sudo dpkg -i linux-*.deb
popd

if [ -z "$(awk -F\' '/menuentry / {print $2}' /boot/grub/grub.cfg | grep -m 1 'Ubuntu, with Linux 6.5.0-hitchhike+')" ]; then
    printf "Cannot find hitchhike kernel. Please install the kernel manually.\n"
    exit 1
fi

printf "hitchhike kernel is installed. To boot into hitchhike kernel, please run:\n"
printf "    sudo grub-reboot \"Advanced options for Ubuntu>Ubuntu, with Linux 6.5.0-hitchhike+\"\n"
printf "    sudo reboot\n"