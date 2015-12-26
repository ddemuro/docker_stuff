#!/bin/bash

#########################################
# Derek Demuro                          #
#########################################
# Script to have all container data in  #
# /mnt that way we can swap between     #
# physical machines easily, only having #
# to keep track of /mnt.                #
# ##################################### #
# THIS FILE SHOULD BE USED AS TEMPLATE  #
# ##################################### #
#########################################

# Template format:
# echo "What you're doing / mounting"
# mount --bind <source> <destination>
# That way we have clean path's, remember actions in one reflect in another
# that's like creating a symlink.

echo "Mounting gitlab machine"
mount --bind /srv /mnt/gitlab

echo "Binding music location"
mount --bind /mnt/mvd02/ex3TBUSB/Music /mnt/music/Music
mount --bind /mnt/mvd02/ex3TBUSB/Videos /mnt/music/Videos
