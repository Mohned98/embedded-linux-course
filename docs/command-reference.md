# Embedded Linux Command Reference

Quick-reference cheat sheet for the Embedded Linux & Device Driver course.

## Table of Contents

1. [QEMU Basics](#qemu-basics)
2. [Raspberry Pi Image & Boot](#raspberry-pi-image--boot)
    1. [Serial Devices](#serial-devices)
3. [Running Raspberry Pi 3 in QEMU](#running-raspberry-pi-3-in-qemu)
4. [Connecting via SSH](#connecting-via-ssh)
5. [USB Device Sharing (WSL2)](#usb-device-sharing-wsl2)
    1. [Windows](#windows)
    2. [WSL](#wsl)
6. [Raspberry Pi Configuration](#raspberry-pi-configuration)
7. [Init System & systemd](#init-system--systemd)
    1. [Init System](#init-system)
    2. [Systemd Services](#systemd-services)
    3. [Systemd Targets](#systemd-targets)
8. [Boot Log Collection](#boot-log-collection)
    1. [Raspberry Pi](#raspberry-pi)
    2. [WSL](#wsl-1)
9. [Cross Toolchain (AArch64)](#cross-toolchain-aarch64)
10. [U-Boot](#u-boot)
    1. [Environment Variables](#environment-variables)
    2. [Memory Commands](#memory-commands)
    3. [MMC / SD Card](#mmc--sd-card)
    4. [Device Tree (FDT)](#device-tree-fdt)
    5. [Boot Commands](#boot-commands)
        1. [Options](#options)
        2. [Input Example (`boot_cmd.txt`)](#input-example-boot_cmdtxt)
    6. [Image Commands](#image-commands)
    7. [Miscellaneous](#miscellaneous)
    8. [Typical Linux Boot Sequence](#typical-linux-boot-sequence)
11. [Linux Kernel](#linux-kernel)
12. [buildroot](#buildroot)
13. [LKM](#lkm)
14. [Device Drivers](#device-drivers)
15. [Device Tree](#device-tree)

---

## QEMU Basics

```bash
# List available QEMU executables
ls /usr/bin/qemu-*

# List supported CPUs for qemu-arm
qemu-arm -cpu help

# List supported ARM machine models
qemu-system-aarch64 -machine help
```

---

## Raspberry Pi Image & Boot

```bash
# Identify the image format
file 2023-05-03-raspios-bullseye-arm64.img

# Show image partition table
fdisk -l 2023-05-03-raspios-bullseye-arm64.img

# Print partition information
parted 2023-05-03-raspios-bullseye-arm64.img print
```

### Serial Devices

```bash
# List ARM serial devices
ls /dev/ttyA*
```

| Command | Description |
|---------|-------------|
| `ls /dev/ttyA*` | List ARM UART devices (e.g., `ttyAMA0`). |

---

## Running Raspberry Pi 3 in QEMU

```bash
qemu-system-aarch64 \
    -machine raspi3b \
    -cpu cortex-a53 \
    -nographic \
    -dtb bcm2710-rpi-3-b-plus.dtb \
    -m 1G \
    -smp 4 \
    -kernel kernel8.img \
    -drive file=2023-05-03-raspios-bullseye-arm64.img,format=raw,if=sd \
    -append "rw earlyprintk loglevel=8 console=ttyAMA0,115200 dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootdelay=1" \
    -device usb-net,netdev=net0 \
    -netdev user,id=net0,hostfwd=tcp::2222-:22
```

| Option | Description |
|--------|-------------|
| `-machine raspi3b` | Emulate a Raspberry Pi 3 Model B. |
| `-cpu cortex-a53` | Emulate the Cortex-A53 CPU. |
| `-nographic` | Disable graphics and use the serial console. |
| `-dtb` | Load the device tree blob. |
| `-m 1G` | Allocate 1 GB RAM. |
| `-smp 4` | Emulate 4 CPU cores. |
| `-kernel` | Boot the specified Linux kernel. |
| `-drive` | Attach the SD card image. |
| `-append` | Pass kernel boot parameters. |
| `hostfwd=tcp::2222-:22` | Forward host port **2222** to guest SSH port **22**. |

---

## Connecting via SSH

```bash
# Using localhost
ssh -p 2222 pi@localhost

# Equivalent command
ssh pi@127.0.0.1 -p 2222
```

| Command | Description |
|---------|-------------|
| `ssh -p 2222 pi@localhost` | Connect to the Raspberry Pi running in QEMU via SSH. |

---

## USB Device Sharing (WSL2)

### Windows

```bash
# List USB devices
usbipd list

# Share device (replace with your BUSID)
usbipd bind --busid <BUSID>

# Verify device is shared
usbipd list

# Attach device to WSL2
usbipd attach --wsl --busid <BUSID>
```

### WSL

```bash
# List connected USB devices
lsusb

# List block storage devices (disks & partitions)
lsblk

# List block devices with filesystem information
lsblk -f

# Mount boot partition
sudo mount /dev/sdf1 /mnt/boot

# Mount root filesystem
sudo mount /dev/sdf2 /mnt/root
```

---

## Raspberry Pi Configuration

```bash
# Configure Raspberry Pi (SSH, VNC, Interfaces, Localization, etc.)
sudo raspi-config

# NetworkManager text UI
sudo nmtui

# Show the Raspberry Pi IP address
hostname -I

# Reboot Raspberry Pi
sudo reboot
```

---

## Init System & systemd

### Init System

```bash
# Show the init system (PID 1)
ps -p 1 -o comm=

# List running services
systemctl

# Service status
systemctl status ssh

# Start a service
sudo systemctl start ssh

# Stop a service
sudo systemctl stop ssh

# Enable service at boot
sudo systemctl enable ssh

# Disable service at boot
sudo systemctl disable ssh

# Print service
systemctl cat ssh
```

### Systemd Services

```ini
/etc/systemd/system/hello.service
[Unit]
# Human-readable description of the service
Description=Hello Demo

[Service]
# Command executed when the service starts
ExecStart=/usr/bin/bash -c "while true; do echo Hello; sleep 5; done"

[Install]
# Start this service when the system reaches the multi-user target
WantedBy=multi-user.target
```

```bash
# Reload systemd to detect the new unit file
sudo systemctl daemon-reload

# Start the service
sudo systemctl start hello

# Show the current status of the service
sudo systemctl status hello

# View logs generated by the service
journalctl -u hello

# Follow the service logs in real time
journalctl -u hello -f
```

### Systemd Targets

```bash
# Show the default boot target
systemctl get-default

# List active targets
systemctl list-units --type=target

# Show all units required by the multi-user target
systemctl list-dependencies multi-user.target

# List services enabled for the multi-user target
ls -l /etc/systemd/system/multi-user.target.wants/

# Enable the hello service to start automatically at boot
sudo systemctl enable hello

# Verify that hello.service is linked to the multi-user target
ls -l /etc/systemd/system/multi-user.target.wants/
```

---

## Boot Log Collection

### Raspberry Pi

```bash
# Save the current boot log to a file
journalctl -b > boot.log
```

### WSL

```bash
# Copy the boot log from Raspberry Pi to the current directory in WSL
scp pi@192.168.1.100:/home/pi/boot.log .

scp -P 2222 pi@localhost:/home/pi/bootqemu.log .
```

---

## Cross Toolchain (AArch64)

```bash
# Show GCC version
aarch64-linux-gnu-gcc --version

# Show GCC installation path
which aarch64-linux-gnu-gcc

# Compile
aarch64-linux-gnu-gcc -static hello.c -o hello

# Test
qemu-arm64 hello

# Compile with debug symbols
aarch64-linux-gnu-gcc -g hello.c -o hello

# Compile only (no linking)
aarch64-linux-gnu-gcc -c hello.c

# Generate assembly
aarch64-linux-gnu-gcc -S hello.c

# Show executable type
file hello

# Display assembly
aarch64-linux-gnu-objdump -d hello

# List symbols
aarch64-linux-gnu-nm hello

# Show GDB version
aarch64-linux-gnu-gdb --version

# Launch GDB with the target executable
aarch64-linux-gnu-gdb hello

# Set a breakpoint at main()
(gdb) break main

# Start/continue execution
(gdb) run
(gdb) continue

# Step through the program
(gdb) step

# Quit GDB
(gdb) quit

# Compare between static and dynamic linking
ls -lh

# Add toolchain to PATH var
export PATH=$HOME/x-tools/arm-edges-linux-gnueabihf/bin:$PATH
export PATH=$HOME/x-tools/aarch64-edges-linux-gnu/bin:$PATH
```

---

## U-Boot

```bash
export ARCH=arm64
export CROSS_COMPILE=aarch64-edges-linux-gnu-
make rpi_4_defconfig

export ARCH=arm
export CROSS_COMPILE=arm-edges-linux-gnueabihf-
make vexpress_ca9x4_defconfig

make menuconfig
make -j$(nproc)
```

```bash
# Show all available commands
help

# Show help for a specific command
help printenv

# Display U-Boot version
version

# Display board information
bdinfo

# Display console devices
coninfo

```

### Environment Variables

```bash
# Print all environment variables
printenv

# Print a specific variable
printenv bootcmd
printenv bootargs
printenv kernel_addr_r

# Create or modify an environment variable
setenv bootdelay 5

# Edit an environment variable
editenv bootcmd

# Read an environment variable from the terminal
askenv serverip

# Save environment variables permanently
saveenv

# Restore factory default environment
env default -a

# Print text or expand variables
echo Hello
echo ${bootcmd}

# Execute commands stored in variables
run bootcmd
run cmd1 cmd2
```

### Memory Commands

```bash
# Display memory contents
md ${kernel_addr_r}

# Display multiple words
md ${kernel_addr_r} 20

# Modify memory (auto-increment address)
mm ${loadaddr}
mm 0x100000

# Modify a fixed memory location
nm ${loadaddr}

# Write a value repeatedly into memory
mw ${loadaddr} 0xAA 64

# Copy memory
cp.b ${kernel_addr_r} ${loadaddr} 0x1000

# Compare memory regions
cmp.b ${kernel_addr_r} ${loadaddr} 0x1000

```

### MMC / SD Card

```bash
# List MMC devices
mmc list

# Display MMC information
mmc info

# Display FAT filesystem information
fatinfo mmc 0:1

# List files in a FAT partition
fatls mmc 0:1

# Load a file from a FAT partition into RAM
fatload mmc 0:1 ${kernel_addr_r} Image

# List files in an ext4 partition
ext4ls mmc 0:2 /

# Load a file from an ext4 partition
ext4load mmc 0:2 ${loadaddr} /boot/Image
```

### Device Tree (FDT)

```bash
# Select a Device Tree Blob
fdt addr ${fdt_addr}

# Select another Device Tree Blob
fdt addr ${fdt_addr_r}

# Display the FDT header
fdt header

# Print the entire Device Tree
fdt print
```

### Boot Commands

```bash
# Boot using the default boot command
boot

# Boot an ARM64 Linux Image
booti ${kernel_addr_r} - ${fdt_addr_r}

# Boot a legacy uImage
bootm ${loadaddr}

# Boot a compressed zImage
bootz ${kernel_addr_r} - ${fdt_addr_r}

# Convert a text file containing U-Boot commands into a boot script image
mkimage -T script -C none -n "Boot script" -d boot_cmd.txt boot.scr

# Display information about the generated boot script
mkimage -l boot.scr

# Execute a boot script
source ${scriptaddr}
```

#### Options

| Option | Description |
|--------|-------------|
| `-T script` | Specifies that the image type is a U-Boot script. |
| `-C none` | No compression is applied to the script. |
| `-n "Boot script"` | Sets a descriptive name stored in the image header. |
| `-d <input_file>` | Specifies the input text file containing U-Boot commands. |
| `<output_file>` | The generated U-Boot script image (e.g., `boot.scr`). |

#### Input Example (`boot_cmd.txt`)

```bash
fatload mmc 0:1 ${kernel_addr_r} Image
fatload mmc 0:1 ${fdt_addr_r} bcm2711-rpi-4-b.dtb
setenv bootargs "console=ttyAMA0,115200 root=/dev/mmcblk0p2 rw rootwait"
booti ${kernel_addr_r} - ${fdt_addr_r}
```

### Image Commands

```bash
# Display information about a U-Boot image
iminfo ${loadaddr}
```

### Miscellaneous

```bash
# Reset the board
reset

# Delay execution
sleep 5
```

### Typical Linux Boot Sequence

```bash
# Select the SD card
mmc dev 0

# List boot partition files
fatls mmc 0:1

# Load the Linux kernel
fatload mmc 0:1 ${kernel_addr_r} Image

# Load the Device Tree
fatload mmc 0:1 ${fdt_addr_r} bcm2711-rpi-4-b.dtb

# Set kernel command line
setenv bootargs "console=ttyAMA0,115200 root=/dev/mmcblk0p2 rw rootwait"

# Boot Linux
booti ${kernel_addr_r} - ${fdt_addr_r}


# For Qemu TFTP
tftp ${kernel_addr_r} ${kernel_image}
tftp ${fdt_addr_r} ${fdt_file}
tftp ${ramdisk_addr_r} ${initramfs}
bootz ${kernel_addr_r} ${ramdisk_addr_r} ${fdt_addr_r}
```

---

## Linux Kernel

```bash
export ARCH=arm
export CROSS_COMPILE=arm-edges-linux-gnueabihf-
make vexpress_defconfig
make -j$(nproc) zImage dtbs
```

---

## buildroot

```bash
# Run linux-menuconfig with a clean PATH.
# Useful when PATH contains Windows paths or tabs/spaces.
env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" make linux-menuconfig

# Set a simple Bash prompt:
# username@hostname:current_directory$
export PS1='\u@\h:\w\$ '

```

---

## LKM

```bash
# Display information about the kernel module.
modinfo mymodule.ko

# Insert/load the kernel module.
insmod mymodule.ko

# List currently loaded kernel modules.
lsmod

# Remove/unload the kernel module.
rmmod mymodule

# Read a module parameter from sysfs.
cat /sys/module/hello/parameters/{param}

# Write a new value to a module parameter.
echo 40 > /sys/module/hello/parameters/{param}

```

## Device Drivers

```bash
# List all registered devices with their major numbers
cat /proc/devices

# Check gcc machine type
gcc -dumpmachine

# Check LED trigger type
cat /sys/class/leds/PWR/trigger

# Disable LED trigger
echo none | sudo tee /sys/class/leds/PWR/trigger

# Check LED brightness level
cat /sys/class/leds/PWR/brightness

# Enable LED (set brightness to 1)
echo 1 | sudo tee /sys/class/leds/PWR/brightness

```

## Device Tree

```bash
# 1. Mount ConfigFS
sudo mount -t configfs none /sys/kernel/config

# 2. Create an overlay directory
sudo mkdir /sys/kernel/config/device-tree/overlays/my_overlay

# 3. Apply the compiled overlay
sudo sh -c 'cat mychardev_overlay_example.dtbo > \
    /sys/kernel/config/device-tree/overlays/my_overlay/dtbo'

```