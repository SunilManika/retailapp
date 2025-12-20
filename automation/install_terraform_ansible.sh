#!/usr/bin/env bash
set -euo pipefail

echo "==========================================="
echo " Installing Terraform and Ansible"
echo "==========================================="

# Must run as root
if [[ "$EUID" -ne 0 ]]; then
  echo "ERROR: Please run as root or with sudo"
  exit 1
fi

# Detect OS
if [[ -f /etc/os-release ]]; then
  . /etc/os-release
else
  echo "ERROR: Cannot detect OS"
  exit 1
fi

echo "Detected OS: $NAME"

############################################
# Install prerequisites
############################################
install_prereqs() {
  if [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
    apt-get update -y
    apt-get install -y \
      curl \
      wget \
      unzip \
      gnupg \
      software-properties-common \
      python3 \
      python3-pip

  elif [[ "$ID" == "rhel" || "$ID_LIKE" == *"rhel"* || "$ID" == "rocky" || "$ID" == "almalinux" ]]; then
    yum install -y \
      yum-utils \
      curl \
      wget \
      unzip \
      python3 \
      python3-pip

  elif [[ "$ID" == "amzn" ]]; then
    yum install -y \
      yum-utils \
      curl \
      wget \
      unzip \
      python3 \
      python3-pip
  else
    echo "ERROR: Unsupported OS"
    exit 1
  fi
}

############################################
# Install Terraform
############################################
install_terraform() {
  echo "Installing Terraform..."

  TERRAFORM_VERSION="1.8.5"

  cd /tmp
  wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  unzip -o terraform_${TERRAFORM_VERSION}_linux_amd64.zip
  mv terraform /usr/local/bin/
  chmod +x /usr/local/bin/terraform

  terraform version
}

############################################
# Install Ansible
############################################
install_ansible() {
  echo "Installing Ansible..."

  if [[ "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
    apt-add-repository --yes --update ppa:ansible/ansible
    apt-get install -y ansible

  elif [[ "$ID" == "rhel" || "$ID_LIKE" == *"rhel"* || "$ID" == "rocky" || "$ID" == "almalinux" ]]; then
    dnf install ansible-core -y

  elif [[ "$ID" == "amzn" ]]; then
    amazon-linux-extras enable ansible2
    yum install -y ansible
  fi

  ansible --version
}

############################################
# Execute
############################################
install_prereqs
install_terraform
install_ansible

echo "==========================================="
echo " Terraform and Ansible installation done"
echo "==========================================="
