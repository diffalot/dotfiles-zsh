#!/usr/bin/env bash

sudo cryptsetup open --type luks /dev/sdb2 rescue

echo ""
echo "Authentication Accepted"
echo "Waiting 5 Seconds to Transfer Files"
echo ""

sleep 5

echo "Mounting Rescue Volume"
echo ""
sudo mount /dev/mapper/rescue-root /mnt

echo "Copying List of Currently Installed Packages"
echo ""
pacman -Qe | awk '{print $1}' > /tmp/installed_packages.txt
sudo mv /tmp/installed_packages.txt /mnt/sterling_package_list.txt

echo "Copying Changed Files"
echo ""
cd /home/diff
sudo rsync -axX --exclude .cache --exclude .config/google-chrome --exclude '.vim/tmp/*' --exclude Videos --exclude Desktop --exclude 'build/linux-*' --progress --partial --delete /home/diff/ /mnt/home/diff/

echo "Unmounting Rescue Volume"
echo ""
sudo sync
sudo umount /mnt

# TODO figure out why devicemapper won't close the rescue lvm
#sudo cryptosetup close /dev/mapper/rescue-root
#sudo cryptsetup close /dev/mapper/rescue
