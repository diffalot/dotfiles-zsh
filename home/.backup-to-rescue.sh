#!/usr/bin/env bash

cd "$(dirname "$0")"

TARGET_DRIVE=$1

sudo cryptsetup open --type luks $TARGET_DRIVE'2' rescue

echo ""
echo "Authentication Accepted"
echo "Waiting 5 Seconds to Transfer Files"

sleep 5

echo ""
echo "Mounting Rescue Volume"
echo ""
sudo mount /dev/mapper/rescue-root /mnt
sudo mount $TARGET_DRIVE'1' /mnt/boot

echo ""
echo "Copying List of Currently Installed Packages"
echo ""
pacman -Qe | awk '{print $1}' > /tmp/installed_packages.txt
sudo mv /tmp/installed_packages.txt /mnt/sterling_package_list.txt
# vv How to compare two lists of files
# http://stackoverflow.com/questions/11099894/comparing-2-unsorted-lists-in-linux-listing-the-unique-in-the-second-file

echo ""
echo "Updating Rescue System"
echo ""
sudo pacman-key --refresh-keys
sudo arch-chroot /mnt pacman -Syu

echo ""
echo "Copying Changed Files"
echo ""
cd /home/diff
sudo rsync -axX --exclude .android --exclude '.AndroidStudio*' --exclude .clipboard --exclude .cache --exclude .config/google-chrome --exclude '.vim/tmp/*' --exclude .cpanm --exclude .ipfs --exclude .gem --exclude .local/share --exclude .mozilla --exclude .multirust --exclude .node-gyp --exclude .nvm --exclude .npm --exclude .plenv --exclude .pyenv --exclude .rbenv --exclude .wine --exclude .winetricks --exclude Android --exclude AndroidStudioProjects --exclude Media --exclude 'My Games' --exclude node_modules --exclude Desktop --exclude Downloads --exclude 'build/linux-*' --exclude 'build/UnrealEngine' --exclude 'edgetheory/**/db-dumps/*.sql' --progress --partial --delete /home/diff/ /mnt/home/diff/

echo ""
echo "Unmounting Rescue Volume"
echo ""
sudo sync
df -h /mnt
sudo umount -R /mnt
sudo vgchange -a n rescue # FIXME maybe this command isn't needed anymore
sudo cryptsetup close /dev/mapper/rescue

echo ""
echo "You May Now Remove the Rescue Drive"
echo ""
