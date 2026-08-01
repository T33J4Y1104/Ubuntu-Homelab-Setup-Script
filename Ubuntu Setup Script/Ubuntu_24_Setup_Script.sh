#!/bin/bash

# Basic Seteup script for Ubuntu

echo "------------------------------------"
echo "Setup Script for homelab Ubuntu 24.04 LTS"
echo "By: TJ Tiede"
echo "This script will install curl, net-tools, samba, fastfetch, OpenSSH, Docker, Docker compose, Cockpit, Dockge, and Tailscale"

echo "------------------------------------"
echo "------------------------------------"

apt update 
apt upgrade -y

echo ""
echo "------------------------------------"
echo "Installing basic tools (curl, net-tools, samba, fastfetch)"
echo "------------------------------------"
echo "------------------------------------"

if ! command -v curl &> /dev/null; then
    echo "curl is not installed, installing..."
    apt install -y curl
else
    echo "curl is already installed"
fi
if ! command -v ifconfig &> /dev/null; then
    echo "net-tools is not installed, installing..."
    apt install -y net-tools
else
    echo "net-tools is already installed"
fi

if ! command -v fastfetch &> /dev/null; then
    echo "fastfetch is not installed, installing..."
     wget -qO fastfetch.tar.gz https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-amd64.tar.gz
     sudo tar xf fastfetch.tar.gz --strip-components=3 -C /usr/local/bin fastfetch-linux-amd64/usr/bin/fastfetch
     fastfetch --version
     rm -rf fastfetch.tar.gz
else
    echo "fastfetch is already installed"
fi
if ! command -v smbd &> /dev/null; then
    echo "samba is not installed, installing..."
    apt install -y samba
else
    echo "samba is already installed"
fi

echo "------------------------------------"
echo "Basic tools installation complete"
echo "------------------------------------"
echo "------------------------------------"


echo ""
echo "------------------------------------"
echo "checking for OpenSSH installation"
echo "------------------------------------"
echo "------------------------------------"
if command -v ssh &> /dev/null; then
    echo "OpenSSH is already installed"
    if ! systemctl is-active --quiet ssh; then
        echo "Starting OpenSSH service"
        systemctl start ssh
    fi
    if ! systemctl is-enabled --quiet ssh; then
        echo "Enabling OpenSSH service"
        systemctl enable ssh
    fi
else
    echo "Installing OpenSSH"
    apt install -y openssh-server
    systemctl start ssh
    systemctl enable ssh
fi

echo "------------------------------------"
echo "OpenSSH Server installation complete"
echo "------------------------------------"
echo "------------------------------------"


echo ""
echo "------------------------------------"
echo "Checking for docker installation"
echo "------------------------------------"
echo "------------------------------------"
if command -v docker &> /dev/null; then
    echo "Docker is already installed"
else
    echo "Installing Docker"
    apt install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    apt update
    apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

fi

echo "------------------------------------"
echo "Docker installation complete"
echo "------------------------------------"
echo "------------------------------------"

echo "------------------------------------"
echo "installing Cockpit"
echo "------------------------------------"
echo "------------------------------------"

echo "------------------------------------"
echo "Enabling noble-backports repository"
echo "------------------------------------"
if ! grep -rq "^deb .*noble-backports" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null; then
    echo "deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse" | tee /etc/apt/sources.list.d/noble-backports.list
fi
apt update
# load OS metadata
sudo apt install -t noble-backports cockpit -y

echo "------------------------------------"
echo "Cockpit install complete"
echo "------------------------------------"
echo "------------------------------------"

echo "------------------------------------"
echo "Installing Dockge"
echo "------------------------------------"
echo "------------------------------------"
mkdir -p /opt/stacks /opt/dockge
cd /opt/dockge
curl https://raw.githubusercontent.com/louislam/dockge/master/compose.yaml --output compose.yaml

sudo docker compose up -d

echo ""
echo "------------------------------------"
echo "Dockge installation complete"
echo "------------------------------------"
echo "------------------------------------"

echo ""
echo "------------------------------------"
echo "System Update, Upgrade, and Clean Up"
echo "------------------------------------"
echo "------------------------------------"
apt update
apt install --fix-missing -y
apt upgrade --allow-downgrades -y
apt full-upgrade --allow-downgrades -y
## System Clean Up
apt install -f
apt autoremove -y
apt autoclean
apt clean

echo ""
echo "------------------------------------"
echo "Installing Tailscale"
echo "------------------------------------"
echo "------------------------------------"
if command -v tailscale &> /dev/null; then
    echo "Tailscale is already installed"
else
    echo "Installing Tailscale"
    sudo curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up
fi





