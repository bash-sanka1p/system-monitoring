#!/bin/bash
# Install docker on Debian Based System
# Source: https://docs.docker.com/engine/install/debian/

# Check for root perms
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This Script must be run as root. Use sudo $0"
    exit 1
fi

# Uninstall unofficial versions
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Create group docker.
sudo groupadd docker

echo -e "Run below command to add current user to docker group\n"
echo 'sudo usermod -aG docker $USER'
