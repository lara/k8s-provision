#!/bin/bash

export DEV=disk1
export IMAGE=2020-02-13-raspbian-buster-lite.img

time dd if=$IMAGE of=/dev/$DEV bs=1m

sync

diskutil mount -mountPoint /mnt/rpi/boot /dev/${DEV}s1 
sudo ext4fuse /dev/${DEV}s2 /mnt/rpi/root -o allow_other

# Add SSH key
mkdir -p /mnt/rpi/root/home/pi/.ssh/
cat authorized_keys > /mnt/rpi/root/home/pi/.ssh/authorized_keys

# Enable SSH
touch /mnt/rpi/boot/ssh

# Disable password login
sed -ie s/#PasswordAuthentication\ yes/PasswordAuthentication\ no/g /etc/ssh/sshd_config

# Set hostname
sed -ie s/raspberrypi/node-1/g /etc/hostname
sed -ie s/raspberrypi/node-1/g /etc/hosts

# Reduce GPU memory to minimum
echo "gpu_mem=16" >> /mnt/rpi/boot/config.txt

# Set static IP
cp dhcpcd.conf dhcpcd.conf.orig
sed s/100/101/g dhcpcd.conf > dhcpcd.conf

# Unmount the SD card
umount /mnt/rpi/boot
umount /mnt/rpi/root

sync

# Remove password for the current user
sudo visudo
pi ALL=(ALL) NOPASSWD:ALL
sudo passwd -d `whoami`

# Set up wifi
sudo su
wpa_passphrase "NAME" "password" >> /etc/wpa_supplicant/wpa_supplicant.conf
# rNOTE: Remove cleartext password from wpa_supplicant.conf

wpa_cli reconfigure

sudo reboot


