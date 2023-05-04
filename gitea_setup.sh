#!/bin/bash

# Update package lists and install required dependencies
sudo apt update
sudo apt install -y git wget sqlite3

# Download and extract the Gitea binary
GITEA_VERSION="1.16.0"
wget -O gitea https://dl.gitea.io/gitea/${GITEA_VERSION}/gitea-${GITEA_VERSION}-linux-amd64
chmod +x gitea

# Move Gitea to the /usr/local/bin directory
sudo mv gitea /usr/local/bin/

# Create user and directories for Gitea
sudo adduser --system --shell /bin/bash --group --disabled-password --home /home/git git
sudo mkdir -p /var/lib/gitea/{custom,data,log}
sudo chown -R git:git /var/lib/gitea/
sudo chmod -R 750 /var/lib/gitea/

# Set up Gitea as a system service
sudo tee /etc/systemd/system/gitea.service <<EOL
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target

[Service]
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
ExecStart=/usr/local/bin/gitea web -c /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOL

# Configure Gitea
sudo mkdir -p /etc/gitea
sudo chown -R root:git /etc/gitea
sudo chmod -R 770 /etc/gitea

# Start and enable Gitea service
sudo systemctl daemon-reload
sudo systemctl enable --now gitea

echo "Gitea installation completed. Access the web interface on http://00:0d:3a:55:d6:e3 brd ff:ff:ff:ff:ff:ff:3000 to complete the setup."
