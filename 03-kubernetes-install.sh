#!/bin/bash -e

# This installs/configures kubeadm and supporting packages.
# It closely follows the official kubeadm docs.
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

K8S_VERSION=1.15.5 # 'apt-cache madison kubectl' will tell you available versions

# Add Kubernetes yum repo
echo "Enabling Kubernetes yum repo"
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get clean
apt-get update

# Install Kubernetes binaries
echo "Installing Kubernetes binaries..."
apt-get install -y kubelet="${K8S_VERSION}-00" kubeadm="${K8S_VERSION}-00" kubectl="${K8S_VERSION}-00"
apt-mark hold kubelet kubeadm kubectl

# Prefetch kubeadm images
echo "Prefetching Kubernetes Images. This may take a minute..."
kubeadm config images pull --kubernetes-version ${K8S_VERSION}

# Cleanup
echo "Cleaning up apt data..."
apt autoremove --purge -y
apt update

# Finish
echo ""
echo "Setup complete. Reboot for all changes to take effect."
echo ""