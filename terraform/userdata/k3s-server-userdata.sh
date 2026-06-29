#!/bin/bash

set -e
set -o pipefail

LOG_FILE="/var/log/k3s-server-userdata.log"

exec > >(tee -a ${LOG_FILE}) 2>&1

echo "========== K3s Server Installation Started =========="
date

export DEBIAN_FRONTEND=noninteractive

echo "========== Updating Ubuntu =========="

apt-get update -y
apt-get upgrade -y

echo "========== Installing Required Packages =========="

apt-get install -y \
    curl \
    wget \
    git \
    unzip \
    apt-transport-https \
    ca-certificates

echo "========== Installing K3s Server =========="

curl -sfL https://get.k3s.io | sh -

echo "========== Waiting for K3s to Start =========="

sleep 30

systemctl enable k3s

systemctl is-active k3s

echo "========== Configuring kubectl =========="

mkdir -p /root/.kube

cp /etc/rancher/k3s/k3s.yaml /root/.kube/config

chmod 600 /root/.kube/config

export KUBECONFIG=/root/.kube/config

echo "========== Verifying Cluster =========="

kubectl get nodes

echo "========== Saving Cluster Information =========="

echo "Node Token:"
cat /var/lib/rancher/k3s/server/node-token

echo "Kubernetes Nodes:"
kubectl get nodes

echo "========== K3s Server Installation Completed =========="
date