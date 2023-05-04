#!/bin/bash

# Update the system
sudo apt update
sudo apt upgrade -y

# Install required dependencies
sudo apt install -y wget unzip git postgresql postgresql-contrib

# Create a system user for Gitea
sudo adduser \
   --system \
   --shell /bin/bash \
   --gecos 'Git Version Control' \
   --group \
   --disabled-password \
   --home /home/gitea \
   gitea

# Download and install Gitea
sudo wget -O /tmp/gitea https://dl.gitea.io/gitea/1.15.6/gitea-1.15.6-linux-amd64
sudo chmod +x /tmp/gitea
sudo mv /tmp/gitea /usr/local/bin

# Create Gitea directories
sudo mkdir -p /var/lib/gitea/{custom,data,log}
sudo chown -R gitea:gitea /var/lib/gitea/
sudo chmod -R 750 /var/lib/gitea/

# Create Gitea service file
sudo bash -c 'cat > /etc/systemd/system/gitea.service << EOL
[Unit]
Description=Gitea (Git with a cup of tea)
After=syslog.target
After=network.target
After=postgresql.service

[Service]
LimitMEMLOCK=infinity
LimitNOFILE=65535
RestartSec=2s
Type=simple
User=gitea
Group=gitea
WorkingDirectory=/var/lib/gitea/
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=gitea HOME=/home/gitea GITEA_WORK_DIR=/var/lib/gitea
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOL'

# Create PostgreSQL user and database for Gitea
sudo -u postgres psql -c "CREATE USER gitea WITH PASSWORD 'your_password';"
sudo -u postgres psql -c "CREATE DATABASE giteadb OWNER gitea;"

# Set up Gitea configuration file
sudo mkdir -p /etc/gitea
sudo chown -R gitea:gitea /etc/gitea
sudo chmod -R 750 /etc/gitea
sudo -u gitea bash -c 'cat > /etc/gitea/app.ini << EOL
APP_NAME = Gitea: Git with a cup of tea
RUN_USER = gitea
RUN_MODE = prod

[server]
HTTP_ADDR = ::
HTTP_PORT = 3000
ROOT_URL = http://localhost:3000/

[database]
DB_TYPE  = postgres
HOST     = 127.0.0.1:5432
NAME     = giteadb
USER     = gitea
PASSWD   = your_password

[repository]
ROOT = /home/gitea/gitea-repositories

[security]
INSTALL_LOCK = true
SECRET_KEY = !#@FDEWREWR&*(

[service]
DISABLE_REGISTRATION = false
NO_REPLY_ADDRESS = noreply.localhost
EOL'

sudo chown -R gitea:gitea /etc/gitea/app.ini
sudo chmod -R 750 /etc/gitea/app.ini

# Enable and start Gitea service
sudo systemctl daemon-reload
sudo
