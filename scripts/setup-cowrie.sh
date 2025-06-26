#!/bin/bash

#This script goes into the bootfs for the raspberry pi. after, add it to the rc.local file. Also add rc.local 

# Set static IP by appending to dhcpcd.conf
echo -e "\ninterface eth0\nstatic ip_address=192.168.7.2/24\nstatic routers=192.168.7.1\nstatic domain_name_servers=8.8.8.8 1.1.1.1" >> /etc/dhcpcd.conf

# Install Cowrie dependencies
apt update && apt install -y git python3-venv libssl-dev libffi-dev build-essential

# Create cowrie user
adduser --disabled-password --gecos "" cowrie

# Install Cowrie
sudo -u cowrie bash << EOF
cd /home/cowrie
git clone https://github.com/cowrie/cowrie.git
cd cowrie
python3 -m venv cowrie-env
source cowrie-env/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
cp etc/cowrie.cfg.dist etc/cowrie.cfg
cp etc/userdb.txt.dist etc/userdb.txt
EOF

# Cleanup: remove script after execution
rm -f /boot/setup-cowrie.sh
