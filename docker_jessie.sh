#!/bin/bash
#############################################
# Derek Demuro                              #
#############################################
# This script is intended to assist with    #
# docker installation, and tweak the system #
# for correct docker support.               #
#############################################
readonly PKG_MGR="apt-get"
readonly PKG_TO_INSTALL="htop rsync iotop iftop vim mtr apt-transport-https curl zsh git"
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
                echo 'etcd Port number, normally 4001..., you have to type it!.'
                read shipyard_port
                curl -sSL $SHIPYARD_URL | ACTION=node DISCOVERY="etcd://$shipyard_ip:$shipyard_port" bash -s
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

# Ohh my zsh installation
echo 'Should we install Oh-My-ZShell?'
read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
        sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
        rm /root/.zshrc
        wget https://raw.githubusercontent.com/ddemuro/docker_stuff/master/other-niceness/zshrc -O /root/.zshrc
        ;;
    *)
        echo 'Ohh my zshell installation cancelled.'
        ;;
esac

# Other scripts from repo
echo 'Should we install other useful scripts?'
read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
        echo "Adding bind mounts, for docker containers in our workflow."
        wget https://raw.githubusercontent.com/ddemuro/docker_stuff/master/docker_mounts.sh -O /mnt/docker_mounts.sh
        echo "Setting permissions for execution of script"
        chmod +x /mnt/docker_mounts.sh        
        ;;
    *)
        echo 'Ohh my zshell installation cancelled.'
        ;;
esac

## Adding dockermounts to use remote folders.
echo "Adding /mnt/docker_mounts.sh to crontab -e with @reboot"
(crontab -u root -l; echo "@reboot /mnt/docker_mounts" ) | crontab -u root -

# Other scripts from repo
echo 'Should we grab the fstab from repo?'
read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
        echo "Replacing fstab."
        wget https://raw.githubusercontent.com/ddemuro/docker_stuff/master/other-niceness/fstab -O /etc/fstab
        ;;
    *)
        echo 'Fstab was not grabbed from repo.'
        ;;
esac
