#!/bin/bash -e

# Fix for iptables issues in Debian Buster
update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# Disable swap
service dphys-swapfile stop
systemctl disable dphys-swapfile
apt-get purge -y dphys-swapfile

# Install in Configure Docker
echo "Installing Docker"
DEBIAN_FRONTEND=noninteractive apt-get -y install docker.io

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

systemctl daemon-reload
systemctl restart docker

apt-mark hold docker.io