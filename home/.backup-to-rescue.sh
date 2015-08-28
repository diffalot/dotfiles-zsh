#!/usr/bin/env bash

sudo cryptsetup open --type luks /dev/sdb2 rescue

echo "Password Accepted, waiting 5 seconds to transfer files"

sleep 5

sudo mount /dev/mapper/rescue-root /mnt

pacman -Qe | awk '{print $1}' > /tmp/package_list.txt

sudo mv /tmp/package_list.txt > /mnt/package_list.txt

cd /home/diff

sudo rsync -axX --exclude .cache --exclude .config/google-chrome --exclude '.vim/tmp/*' --exclude Videos --exclude Desktop --exclude 'build/linux-*' --progress --partial --delete /home/diff/ /mnt/home/diff/

sudo sync

sudo umount /mnt

#sudo cryptosetup close /dev/mapper/rescue-root

#sudo cryptsetup close /dev/mapper/rescue
