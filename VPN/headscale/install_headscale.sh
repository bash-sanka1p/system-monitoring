#!/bin/sh
# Install headscale on debain
# Author: Sankalp Singh Bais (bash.sankalp@gmail.com)
# Reference: https://headscale.net/stable/setup/install/official/
set -e

# Check for root perms
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This Script must be run as root. Use sudo $0"
    exit 1
fi

HEADSCALE_VERSION="0.26.1"
HEADSCALE_ARCH="amd64" #  system architecture, e.g. "amd64"
DOWNLOAD_PATH="/tmp/headscale.deb"

echo "[+] Downloading Headscale ${HEADSCALE_VERSION} for ${HEADSCALE_ARCH}..."
wget --output-document=/tmp/headscale.deb --show-progress  \
"https://github.com/juanfont/headscale/releases/download/v${HEADSCALE_VERSION}/headscale_${HEADSCALE_VERSION}_linux_${HEADSCALE_ARCH}.deb"

echo "[+] Installing Headscale ..."
apt-get install -y "${DOWNLOAD_PATH}"

echo "\nConfig file is located at /etc/headscale/config.yaml"
echo "More details about config file can be found here https://headscale.net/stable/ref/configuration/"
echo "Run below command to enable and start headscale right now"
echo "systemctl enable --now headscale"
