#!/usr/bin/env bash

sudo cryptsetup open --type luks /dev/sdb2 rescue

sleep 5

sudo mount /dev/mapper/rescue-root /mnt

cd /home/diff

sudo rsync -axX --exclude .cache --exclude .config/google-chrome --exclude '.vim/tmp/*' --exclude Videos --exclude Desktop --exclude 'build/linux-*' --progress --partial --delete /home/diff/ /mnt/home/diff/

#sudo ls -alh /mnt/home
#sudo ls -alh /mnt/home/diff
sudo sync

sudo umount -R /mnt

#sudo cryptosetup close /dev/mapper/rescue-root

#sudo cryptsetup close /dev/mapper/rescue
