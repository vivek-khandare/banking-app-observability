#!/bin/bash

set -e
set -o pipefail

LOG_FILE="/var/log/k3s-worker-userdata.log"

exec > >(tee -a ${LOG_FILE}) 2>&1

echo "========== K3s Worker Installation Started =========="
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

echo "========== Worker Ready for Cluster Join =========="

echo "K3s Worker prerequisites installed."

echo "Waiting for manual cluster join..."

date