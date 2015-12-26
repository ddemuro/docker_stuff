# Docker Stuff
For the past weeks, i've been working a lot with Docker.
_Some things_ have been slightly annoying, so I've created some scripts
to _help_ myself during deployment of new container and container machines.

## Normal stack
    1. Install Debian [Latest available]
    2. Install Cloudmin [We use KVM for our Hypervisor].
    3. Spin a new VM with Debian again [Latest available].
    4. Map a drive from _host_ with NFS, and avoid large KVM images.
    5. Use the Docker install script that also installs shipyard.
    6. Try to have machines maxed out of virtual resources.
    7. Set backups of KVM machines (and containers consecuentlly).
    8. Set backup scripts of container data on host machines.

## Issues i've found.
_So far_ None :).

## Will this continue growing?
Hopefully as I deploy more and more containers, i'll start finding minor annoyances.
And as they appear, if I can script them, so will I (Yoda style).
