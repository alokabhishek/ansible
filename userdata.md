SLE 15 SP1

# Ansible from systemsmanagement Project
# https://software.opensuse.org/download.html?project=systemsmanagement&package=ansible

sudo zypper addrepo https://download.opensuse.org/repositories/systemsmanagement/SLE_15_SP1/systemsmanagement.repo
sudo zypper refresh
sudo zypper in ansible

Ubuntu 18.04

# Specify Below User Data on EC2 Launch in AWS
# These commands can also be run post EC2 Launch to Install Ansible

#!/bin/bash
apt update
apt install software-properties-common -y
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible -y

