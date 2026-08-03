#!/bin/sh

echo "EDGES For Training - Embedded Linux Course Environment Setup"
mkdir Embedded_Linux
cd Embedded_Linux/
mkdir Labs
cd Labs/

# Update and install necessary packages
echo "Updating system and installing required packages..."
sudo apt update && sudo apt upgrade -y && sudo apt-get dist-upgrade -y
# If pbuilder asks for "Default mirror site", use: http://archive.ubuntu.com/ubuntu
sudo apt install -y build-essential git autoconf bison flex \
 texinfo help2man gawk libtool-bin libncurses5-dev unzip pkg-config python3 python3-pip \
 libglib2.0-dev libpixman-1-dev zlib1g-dev libncurses5-dev \
 libfdt-dev libssl-dev libcurl4-openssl-dev libusb-1.0-0-dev \
 libsdl2-dev libspice-protocol-dev libaio-dev libjpeg-dev \
 libvde-dev libbrlapi-dev libbluetooth-dev libgnutls28-dev \
 libtool libgdk-pixbuf2.0-dev libpixman-1-dev python3-sphinx \
 python3-sphinx-rtd-theme ninja-build gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
 qemubuilder qemu-system-gui qemu-system-arm qemu-utils qemu-system-data qemu-system \
 qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils meson tftpd-hpa \
 autoconf-archive qemu-user device-tree-compiler swig python3-dev python3-setuptools \
 uuid-dev picocom minicom nfs-kernel-server gcc make wget libncurses-dev bc u-boot-tools

# Downloading Lab 1 sources
echo "Downloading Raspberrypi image for Qemu Emulation..."
mkdir Lab1 && cd Lab1
mkdir Qemu && cd Qemu
wget https://downloads.raspberrypi.org/raspios_arm64/images/raspios_arm64-2023-05-03/2023-05-03-raspios-bullseye-arm64.img.xz
xz -d 2023-05-03-raspios-bullseye-arm64.img.xz
cd ../..

# Downloading CrossTool chain sources
mkdir Lab3 && cd Lab3
git clone https://github.com/crosstool-ng/crosstool-ng
cd crosstool-ng/
git switch -c crosstool-ng-1.27.0
./bootstrap
./configure --enable-local
make -j$(nproc)
cd ../..

# Downloading Uboot sources
mkdir Lab4 && cd Lab4
echo "Downloading U-Boot..."
git clone --depth=1 https://github.com/raspberrypi/firmware.git
git clone https://github.com/u-boot/u-boot.git
cd u-boot
git checkout v2025.01
cd ../..

# Downloading Linux sources
echo "Downloading Linux Kernel..."
mkdir Lab5 && cd Lab5
mkdir Qemu && cd Qemu
wget https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.127.tar.xz
tar -xf linux-6.1.127.tar.xz
cd ..

mkdir Rpi && cd Rpi
git clone --depth=1 https://github.com/raspberrypi/linux
cd ../..

# Downloading Busybox sources
echo "Downloading Busybox..."
mkdir Lab6 && cd Lab6
git clone https://git.busybox.net/busybox
cd busybox/
git checkout 1_37_stable
cd ../..


# Downloading Buildroot sources
echo "Downloading Buildroot..."
mkdir Lab7 && cd Lab7
git clone https://github.com/buildroot/buildroot.git
cd buildroot
git checkout 2024.11
cd ../..

# Downloading Kernel headers for device drivers and kernel modules development
sudo apt-get install build-essential kmod linux-headers-$(uname -r)
sudo apt-get update