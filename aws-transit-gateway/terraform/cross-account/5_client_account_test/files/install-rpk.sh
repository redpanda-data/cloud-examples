#!/bin/bash

if command -v rpk &> /dev/null
then
    echo "found rpk, skip the installation"
    exit 0
fi

cd /tmp; curl -LO https://github.com/redpanda-data/redpanda/releases/latest/download/rpk-linux-amd64.zip
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update
# Need NEEDRESTART_MODE=a for not having the prompt to restart services
sudo NEEDRESTART_MODE=a apt install -y unzip
sudo unzip /tmp/rpk-linux-amd64.zip -d /usr/local/bin/
