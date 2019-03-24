#!/usr/bin/env bash

# Guestfish is required
if [[ ! $(command -v guestfish) ]]
then
    echo "Guestfish is required. http://libguestfs.org/"
    exit 1
fi

mkdir -p out tmp

MAC=$1

# Skip extlinux.conf if already present
if [[ ! -f "tmp/uEnv.txt" ]]
then
    # Read from user input if no MAC address was provided as parameter
    if [[ -z "$MAC" ]]
    then
        read -p "Enter MAC address of device []: " MAC
    fi

    # Insert MAC address into extlinux.conf if not empty
    if [[ ! -z "$MAC" ]]
    then
        echo "ethaddr=$MAC" > tmp/uEnv.txt
    fi
fi

# Only download rootfs if needed
if [[ ! -f "tmp/ArchLinuxARM-aarch64-latest.tar.gz" ]]
then
    echo "Downloading Arch Linux ARM rootfs..."
    wget "http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz" -P tmp/
fi

# Create image with guestfish
guestfish -N out/ArchLinuxARM-tx3-mini.img=disk:2G -a bin/u-boot-v2019.01-tx3-mini.bin -f create.gfs -x

echo -en "\n\nImage is ready in out/ArchLinuxARM-tx3-mini.img\n"
