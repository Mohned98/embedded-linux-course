#!/bin/sh

# Downloading Kernel headers for device drivers and kernel modules development
sudo apt-get update
sudo apt-get install build-essential kmod linux-headers-$(uname -r)
sudo apt-get install linux-source
sudo apt-get update

