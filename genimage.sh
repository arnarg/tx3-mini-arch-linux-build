#!/usr/bin/env bash

# Guestfish is required
if [[ ! $(command -v guestfish) ]]
then
    echo "Guestfish is required. http://libguestfs.org/"
    exit 1
fi

mkdir -p out tmp

MAC=$1
RAM=$2

# Skip uEnv.txt if already present
if [[ ! -f "tmp/uEnv.txt" ]]
then
    # Read from user input if no MAC address was provided as parameter
    if [[ -z "$MAC" ]]
    then
        read -p "Enter MAC address of device [none]: " MAC
    fi

    # Insert MAC address into extlinux.conf if not empty
    if [[ ! -z "$MAC" ]]
    then
        echo "ethaddr=$MAC" > tmp/uEnv.txt
    fi
fi

# Skip if u-boot is already present
if [[ ! -f "tmp/u-boot-v2019.01-tx3-mini.bin" ]]
then
    # Read from user input if ram size wasn't provided as a parameter
    if [[ -z "$RAM" ]]
    then
        read -p "Size of RAM in GiB [2]: " RAM
    fi

    # Extract fip dir
    wget -O tmp/u-boot-v2019.01-tx3-mini.bin "https://github.com/arnarg/tx3-mini-uboot-build/releases/download/v2019.01/u-boot-v2019.01-tx3-mini-${RAM:-2}g.bin"
fi

# Only download rootfs if needed
if [[ ! -f "tmp/ArchLinuxARM-aarch64-latest.tar.gz" ]]
then
    echo "Downloading Arch Linux ARM rootfs..."
    wget "http://os.archlinuxarm.org/os/ArchLinuxARM-aarch64-latest.tar.gz" -P tmp/
fi

# Create image with guestfish
guestfish -N out/ArchLinuxARM-tx3-mini.img=disk:2G -a tmp/u-boot-v2019.01-tx3-mini.bin -f create.gfs -x

if [[ "$?" -eq 0 ]]
then
    echo -en "\n\nImage is ready in out/ArchLinuxARM-tx3-mini.img\n"
fi
