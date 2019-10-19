#!/bin/bash -e

# * Manual Steps *
# - Download latest raspbian image
# - Write image to microSD card using Etcher
# - Enable headless ssh - touch /Volumes/boot/ssh
# - Connect Pi to wired network
# - Power on Raspberry Pi
# - Determine IP of Pi

# This prepares a Raspberry Pi running Raspbian Buster to run Kubernetes
# It closely follows the official kubeadm docs.
# https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker

PI_HOSTNAME=pi-master-01
PI_DOMAIN=your-domain.com
PI_IPADDR=10.10.10.10
PI_GATEWAY=10.10.10.1
PI_NAMESERVERS="10.10.10.2 10.10.10.3"
PI_USER=your-user
PI_PASSWORD="your-password"
PI_TIMEZONE="US/Eastern"

# Update Ubuntu
echo "Running apt update/upgrade..."
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade

# Install Additional Packages
echo "Installing Additional Packages..."
DEBIAN_FRONTEND=noninteractive apt-get -y install vim

# Set Hostname
hostnamectl set-hostname "${PI_HOSTNAME}"

# Set IP Address
cat >> /etc/dhcpcd.conf <<EOF
interface eth0
static ip_address=${PI_IPADDR}/24
static routers=${PI_GATEWAY}
static domain_name_servers=1${PI_NAMESERVERS}
static domain_name=${PI_DOMAIN}
static domain_name_search=${PI_DOMAIN}
EOF

# Secure SSH Access
echo "Creating Local User"
useradd -m -s /bin/bash "${PI_USER}"
echo "${PI_USER}:${PI_PASSWORD}" | chpasswd
echo "${PI_USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/011_"${PI_USER}"-nopasswd
chmod 0640 /etc/sudoers.d/011_"${PI_USER}"-nopasswd
usermod --lock --expiredate 1970-01-02 pi

# Set Time Zone
echo "${PI_TIMEZONE}" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

# Set Locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen

cat > /etc/default/locale <<EOF
LANG="en_US.UTF-8"
LANGUAGE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
EOF

LANGUAGE="en_US.UTF-8" LC_ALL="en_US.UTF-8" LANG="en_US.UTF-8" dpkg-reconfigure --frontend=noninteractive locales

# Change Keyboard Layout
cat > /etc/default/keyboard <<EOF
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
EOF

# Cleanup
echo "Cleaning up apt data..."
apt autoremove --purge

# Finish
echo ""
echo "Setup complete. Reboot for all changes to take effect."
echo ""