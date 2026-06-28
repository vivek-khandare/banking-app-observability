#!/bin/bash
set -e

apt-get update -y
apt-get install -y openjdk-17-jdk   # full JDK, not just JRE — mvn needs javac

# --- Git (so Jenkins/you can clone the app repo) ---
apt-get install -y git

# --- Maven (so Jenkins can run mvn clean package) ---
apt-get install -y maven

# --- Jenkins repo + install ---
wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
apt-get update -y
apt-get install -y jenkins

# --- Docker (so Jenkins can build images) ---
apt-get install -y docker.io
usermod -aG docker jenkins

# --- kubectl (so Jenkins can deploy to the k3s cluster) ---
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# --- Helm (for installing the monitoring stack later if needed from here) ---
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

systemctl enable docker
systemctl restart docker
systemctl enable jenkins
systemctl restart jenkins

# --- Sanity check: print versions to /var/log/user-data-versions.log ---
{
  echo "git:     $(git --version)"
  echo "maven:   $(mvn -v | head -1)"
  echo "docker:  $(docker --version)"
  echo "kubectl: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
  echo "helm:    $(helm version --short)"
} > /var/log/user-data-versions.log
