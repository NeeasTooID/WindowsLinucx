#!/bin/bash

# Read config from JSON file
config_file="config.json"
ngrok_token=$(jq -r .ngrok_token "$config_file")
windows_iso_source=$(jq -r .windows_iso_source "$config_file")
disk_image_size=$(jq -r .disk_image_size "$config_file")

# Update package list
sudo apt update -y

# Download bios64.bin
wget -O bios64.bin "https://github.com/BlankOn/ovmf-blobs/raw/master/bios64.bin"

# Download ngrok
wget -O ngrok.tgz "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz"

# Extract ngrok
tar -xf ngrok.tgz

# Set ngrok authtoken
./ngrok authtoken "$ngrok_token"

# Start ngrok tunnel
./ngrok tcp 5900 &

# Install qemu-kvm
sudo apt install qemu-kvm -y

# Create a raw disk image for Windows with specified size
qemu-img create -f raw win.img "$disk_image_size"

# Download Windows ISO from the configured source
wget -O win.iso "$windows_iso_source"

# Run QEMU with specified parameters
sudo qemu-system-x86_64 -drive file=win.iso,media=cdrom -drive file=win.img,format=raw -device usb-ehci,id=usb,bus=pci.0,addr=0x4 -device usb-tablet -vnc :0 -smp cores=2 -device e1000,netdev=n0 -netdev user,id=n0 -vga qxl -accel kvm -bios bios64.bin