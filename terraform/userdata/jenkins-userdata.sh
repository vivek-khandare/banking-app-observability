#!/bin/bash

set -e
set -o pipefail

LOG_FILE="/var/log/jenkins-userdata.log"

exec > >(tee -a ${LOG_FILE}) 2>&1

echo "========== Jenkins User Data Started =========="
date

echo "========== Updating Ubuntu Packages =========="

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y

echo "========== Installing Required Packages =========="

apt-get install -y \
    curl \
    wget \
    unzip \
    git \
    gnupg \
    software-properties-common \
    apt-transport-https \
    ca-certificates

echo "========== Installing Java 17 =========="

apt-get install -y openjdk-17-jdk

java -version

echo "========== Installing Maven =========="

apt-get install -y maven

mvn -version

echo "========== Installing Jenkins =========="

wget -O /usr/share/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

apt-get update -y

apt-get install -y jenkins

systemctl enable --now jenkins

systemctl is-active jenkins

echo "========== Installing Docker =========="

# Create directory for repository keys
install -m 0755 -d /etc/apt/keyrings

# Download Docker GPG Key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker Repository
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
> /etc/apt/sources.list.d/docker.list

apt-get update -y

# Install Docker
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Enable Docker
systemctl enable --now docker
docker info

# Allow Jenkins user to run Docker
usermod -aG docker jenkins

docker --version

echo "========== Installing kubectl =========="

curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

rm -f kubectl

kubectl version --client

echo "========== Installing Helm =========="

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm version --short

echo "========== Configuring Docker Permissions =========="

# Restart Docker Service
systemctl restart docker

# Restart Jenkins Service
systemctl restart jenkins

echo "========== Installed Versions =========="

echo "Java Version:"
java -version

echo "Maven Version:"
mvn -version

echo "Git Version:"
git --version

echo "Docker Version:"
docker --version

echo "Kubectl Version:"
kubectl version --client

echo "Helm Version:"
helm version

echo "Jenkins Status:"
systemctl is-active jenkins

echo "========== Jenkins User Data Completed Successfully =========="
date

