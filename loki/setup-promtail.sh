#!/bin/bash
# Downloads and sets up promtail on debian based systems (Raspberry Pi OS)
# Author: Sankalp Singh Bais (bash.sankalp@gmail.com)
# Source: https://grafana.com/docs/loki/latest/setup/install/local/#install-using-apt-or-rpm-package-manager

set -e

# Check for root perms
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This Script must be run as root. Use sudo $0"
    exit 1
fi

echo "[+] Configuring apt source..."
mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor > /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list

echo "[+] Installing promtail"
apt update && apt-get install promtail -y

echo "[+] Creating Sample config at /etc/promtail/config.yml"

cat > /etc/promtail/config.yml << EOF
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki.server:3100/loki/api/v1/push # replace with the url of your loki server

scrape_configs:
- job_name: system
  static_configs:
  - targets:
      - localhost
    labels:
      job: varlogs
      __path__: /var/log/*log
      stream: stdout
EOF

echo "[!] Modify /etc/promtail/config.yml for server URL and Scrape Configs"

echo "[+] Installtion Finished."
