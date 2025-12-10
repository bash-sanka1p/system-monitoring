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

# Creating directory to store promtail positions file
mkdir -p /var/lib/promtail && chown -R promtail /var/lib/promtail

echo "[+] Creating Sample config at /etc/promtail/config.yml"
cat > /etc/promtail/config.yml << 'EOF'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /var/lib/promtail/positions.yaml

clients:
  - url: http://loki.server:3100/loki/api/v1/push # replace with the url of your loki server

scrape_configs: # Modify accordingly
  - job_name: system
    static_configs:
    - targets:
        - localhost
      labels:
        job: varlogs
        custom_label: custom_value
        name: ${HOSTNAME}
        __path__: /var/log/*log

  - job_name: custom-app-log
    static_configs:
    - targets:
      - localhost
      labels:
        job: custom-app
        name: ${HOSTNAME}
        custom_label: custom_value
        __path__: /path/to/your/custom*.log
EOF

echo "[+] Configuring systemd service for hostname label support ..."
cat > /etc/systemd/system/promtail.service << 'EOF'
[Unit]
Description=Promtail
After=network.target
Wants=network-online.target

[Service]
Type=simple
User=promtail
Environment="HOSTNAME=%H"
ExecStart=/usr/bin/promtail -config.expand-env=true -config.file=/etc/promtail/config.yml
TimeoutSec=30
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

echo "[+] Reloading systemd and enabling promtail ..."
systemctl daemon-reload
systemctl enable --now promtail


echo "[!] Modify /etc/promtail/config.yml for server URL and Scrape Configs."
echo ""
echo "[+] Installation Complete! Check status: systemctl status promtail"
echo "[+] View logs: journalctl -u promtail -f"