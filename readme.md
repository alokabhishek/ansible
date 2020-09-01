1. Install ansible on control host. In my testing I am using an Ubuntu 18.04 EC2 Instance.

$ sudo apt update
$ sudo apt install software-properties-common
$ sudo apt-add-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible

2. Install Purestorage and py-pure-client python SDKs and collections on control host.

$ sudo apt install python3-pip
$ pip3 install purestorage
$ pip3 install py-pure-client
$ ansible-galaxy collection install purestorage.flasharray

3. Launch Ubuntu 18.04 EC2 Initiator with the following user data:

#!/bin/bash
apt update
apt install software-properties-common -y
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible -y

If existing Ubuntu 18.04 VM, install these packages one at a time before proceeding.

4. Replace the content in /etc/ansible/hosts.yaml with the following configuration:

all:
  hosts:
    cloudblockstore:
      ansible_python_interpreter: /usr/bin/python3
    ubuntu:
      ansible_host: <IP of 18.04 VM>
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/<sshkey>.pem
      ansible_python_interpreter: /usr/bin/python3

Replace the ansible_host with the IP from Ubuntu VM launced in Step 3
Replace the ansible_ssh_private_key_file with the SSH Key used to launch the Ubuntu VM in Step 3


5. Create a tmp facts_cache directory

/tmp/facts_cache


6. Modify the /etc/ansible/ansible.cfg with the following content:

[defaults]
inventory = /etc/ansible/hosts
host_key_checking = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/facts_cache
fact_caching_timeout = 7200


7. Login to CBS GUI/CLI and generate API token for array_admin user. Copy API Token.


You are new ready to run some ansible playbooks to automate storage provisioning tasks!
