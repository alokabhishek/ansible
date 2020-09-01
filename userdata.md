# Specify Below User Data on EC2 Launch in AWS
# These commands can also be run post EC2 Launch to Install Ansible

---
openSUSE Leap 15.2

#!/bin/bash
zypper addrepo https://download.opensuse.org/repositories/openSUSE:Leap:15.2/standard/openSUSE:Leap:15.2.repo
zypper refresh
zypper install ansible

---
Ubuntu 18.04

#!/bin/bash
apt update
apt install software-properties-common -y
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible -y

