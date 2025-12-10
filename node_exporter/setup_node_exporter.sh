#!/bin/bash
# Downloads and sets up node_exporter as a service
# Author: Sankalp Singh Bais (bash.sankalp@gmail.com)
# Source: https://prometheus.io/docs/guides/node-exporter/

# Declare node exporter version and architecture
NODE_EXPORTER_VERSION=1.9.1
ARCH=arm64 # amd64 or arm64 for 64 bit

# Check for root perms
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This Script must be run as root. Use sudo $0"
    exit 1
fi

# Download node_exporter from github
URL="https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-$ARCH.tar.gz"
echo "[+] Downloading node_exporter... "
wget -q --show-progress "$URL" -O "/tmp/node_exporter-$NODE_EXPORTER_VERSION.tar.gz"

if [ $? -ne 0 ]; then
    echo "[-] Failed to download node_exporter from $URL"
    exit 1
fi

# Extract tarball and move it to /usr/local/bin/
tar -xzf "/tmp/node_exporter-$NODE_EXPORTER_VERSION.tar.gz" -C /tmp/
cd /tmp/node_exporter-$NODE_EXPORTER_VERSION.*-$ARCH || exit 1
chmod +x node_exporter
mv node_exporter /usr/local/bin

# Create node_exporter user if it does not exist
echo "[+] Creating user for node_exporter"
if ! id -u node_exporter >/dev/null 2>&1; then
    useradd --no-create-home --shell /bin/false node_exporter
fi

# Set ownership
echo "[+] Setting up permissions"
chown node_exporter:node_exporter /usr/local/bin/node_exporter

# Create systemd service file
echo "[+] Creating systemd service"
cat > /etc/systemd/system/node_exporter.service <<EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start node_exporter service
systemctl daemon-reload
systemctl enable --now node_exporter

echo "[+] Node Exporter has been installed and started successfully."
echo "[+] Check service status with: systemctl status node_exporter"