#!/bin/bash -e

# This script is copied to the AMI by Packer and is intended to be run when an
# instance is lanched from the AMI. It will initialize the first master node of a new
# cluster.

K8S_VERSION=1.15.5
K8S_API_EXT_NAME=your-k8s-api-external-hostname.your-domain.com

# Configure Kubernetes Master Node
echo "Starting Kubernetes. This will take several minutes..."
sudo su -c "kubeadm init --kubernetes-version ${K8S_VERSION} \
             --pod-network-cidr=10.244.0.0/16 \
             --apiserver-cert-extra-sans ${K8S_API_EXT_NAME}"

echo "Copying kubeconfig for Kubernetes admin user..."
mkdir -p $HOME/.kube                                                                                                                                                
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config                                                                                                            
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install Flannel
echo "Installing Flannel..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml