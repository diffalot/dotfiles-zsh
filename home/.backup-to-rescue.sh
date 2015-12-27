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
# vv How to compare two lists of files
# http://stackoverflow.com/questions/11099894/comparing-2-unsorted-lists-in-linux-listing-the-unique-in-the-second-file

echo "Copying Changed Files"
echo ""
cd /home/diff
sudo rsync -axX --exclude .cache --exclude .config/google-chrome --exclude '.vim/tmp/*' --exclude Media --exclude Desktop --exclude Downloads --exclude 'build/linux-*' --progress --partial --delete /home/diff/ /mnt/home/diff/

echo ""
echo "Unmounting Rescue Volume"
echo ""
sudo sync
sudo umount /mnt

sudo vgchange -a n rescue # FIXME maybe this command isn't needed anymore
sudo cryptsetup close /dev/mapper/rescue
echo ""
echo "You May Now Remove the Rescue Drive"
echo ""
