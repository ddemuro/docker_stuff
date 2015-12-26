#!/bin/bash

#########################################
# Derek Demuro                          #
#########################################
# Script to have all container data in  #
# /mnt that way we can swap between     #
# physical machines easily, only having #
# to keep track of /mnt.                #
#########################################

# Create base devices (for homes in remote machines)
# This folders should normally be located in /etc/fstab
# see included fstab as example.

echo "Mounting anything from fstab..."
mount -a

echo "Creating remote-homes"
mkdir -p /mnt/mvd02
mkdir -p /mnt/mvd02/ex2TB
mkdir -p /mnt/mvd02/exUSB
mkdir -p /mnt/mvd02/ex3TBUSB
mkdir -p /mnt/mvd02/docker_home
mkdir -p /mnt/mvd01
mkdir -p /mnt/mvd01/docker_home

# Sync homes... at times is necessary
rsync -rtvuz --delete-delay /mnt/mvd02/docker_home/ /mnt/mvd01/docker_home/

echo "Mounting gitlab machine"
mount --bind /srv /mnt/mvd02/docker_home/gitlab

echo "Mounting frontend"
mkdir -p /mnt/frontend
mkdir -p /mnt/mvd01/docker_home/frontend
mkdir -p /mnt/mvd02/docker_home/frontend
mount --bind /mnt/mvd01/docker_home/frontend /mnt/frontend

echo "Binding music location"
mkdir -p /mnt/music
mkdir -p /mnt/music/Music
mkdir -p /mnt/music/Videos
mount --bind /mnt/mvd02/ex3TBUSB/Music /mnt/music/Music
mount --bind /mnt/mvd02/ex3TBUSB/Videos /mnt/music/Videos

#If two or more folders need to be sync'ed
#10.1.0.2:/mnt/docker_home  /mnt/mvd02/docker_home     nfs   timeo=14,intr,bg