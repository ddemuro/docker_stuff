#!/bin/bash
#############################################
# Derek Demuro                              #
#############################################
# This script is intended to assist with    #
# docker installation, and tweak the system #
# for correct docker support.               #
#############################################
readonly PKG_MGR="apt-get"
readonly PKG_TO_INSTALL="htop iotop iftop vim mtr apt-transport-https curl"
readonly GRUB2_DEF_LOC="/etc/default/grub"
readonly DOCKER_SRC_LST="/etc/apt/sources.list.d/docker.list"
readonly DOCKER_SERVICE="docker"
readonly SHIPYARD_URL="http://test.shipyard-project.com/deploy"
readonly EXAMPLES_DWNL=""

# Test grub correctness
if grep -q 'cgroup_enable=memory swapaccount=1' "$GRUB2_DEF_LOC"; then
  echo "cgroup has memory enabled and swap, grub seems okay."
else
  echo "Grub requires fixing, should we fix it?, a reboot is required."
  read -r -p "Are you sure? [y/N] " response
  case $response in
      [yY][eE][sS]|[yY])
          sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"/g' "$GRUB2_DEF_LOC"
          echo "Rebooting in 5 seconds..."
          sleep 5
          shutdown -r now
          ;;
      *)
          echo 'Grub was not fixed, Memory management will not be enforced.'
          ;;
  esac
fi

# Install common tools
echo 'Installing useful tools on server...'
$PKG_MGR -y install $PKG_TO_INSTALL

# Docker installation
echo 'Should we install docker?'
read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
        # Install docker
        apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

        # Add deb to our src list
        echo 'deb https://apt.dockerproject.org/repo debian-jessie main' > $DOCKER_SRC_LST

        # Update package manager
        echo "Adding pkgs."
        $PKG_MGR update
        apt-cache policy docker-engine
        $PKG_MGR update
        echo "Installing docker."
        $PKG_MGR install docker-engine
        echo "Starting docker..."
        service $DOCKER_SERVICE start
        ;;
    *)
        echo 'Docker installation cancelled.'
        ;;
esac

# Shipyard installation
echo 'Should we install shipyard?'
read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
        echo 'Should this be a node in a swarm cluster?'
        read -r -p "Are you sure? [y/N] " response
        case $response in
            [yY][eE][sS]|[yY])
                echo 'Installing machine as node...'
                echo 'Shipyard IP Address to add as node'
                read shipyard_ip
                curl -sSL $SHIPYARD_URL | ACTION=node DISCOVERY=$shipyard_ip:8500 bash -s
                echo "You should now be able to see this machine in Shipyard UI."
                ;;
            *)
                echo 'Installing first node in cluster.'
                curl -sSL $SHIPYARD_URL | bash -s
                echo 'Shipyard should be installed.-'
                ;;
        esac
        ;;
    *)
        echo 'Shipyard installation cancelled.'
        ;;
esac
