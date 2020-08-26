1. Install ansible on control host. In my testing I have been using an ubuntu ec2

$ sudo apt update
$ sudo apt install software-properties-common
$ sudo apt-add-repository --yes --update ppa:ansible/ansible
$ sudo apt install ansible

2. Install Purestorage and py-pure-client python SDKs and collections on control host

$ sudo apt install python3-pip

$ pip3 install purestorage

$ pip3 install py-pure-client

$ ansible-galaxy collection install purestorage.flasharray

3. Launch Ubuntu 18.04 EC2 Initiator with the following Ubuntu user data:

#!/bin/bash
apt update
apt install software-properties-common -y
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible -y

If existing Ubuntu 18.04 VM, install these packages manually before proceeding.

4. Replace the content in /etc/ansible/hosts.yaml with the following configuration:

all:
  hosts:
    cloudblockstore:
      ansible_python_interpreter: /usr/bin/python3
    ubuntu:
      ansible_host: 172.23.2.213
      ansible_user: ubuntu
      ansible_ssh_private_key_file: ~/.ssh/badger.pem
      ansible_python_interpreter: /usr/bin/python3

Replace the ansible_host with the IP from Ubuntu VM launced in Step 3
Replace the ansible_ssh_private_key_file with the SSH Key used to launch the Ubuntu VM in Step 3


5. Create a tmp facts_cache directory

/tmp/facts_cache


6. Edit the /etc/ansible/ansible.cfg with the following contents:

ubuntu@ip-172-23-1-201:~$ cat /etc/ansible/ansible.cfg | grep -v '#' | grep =
inventory = /etc/ansible/hosts
host_key_checking = False
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /tmp/facts_cache
fact_caching_timeout = 7200


7. Login to CBS GUI/CLI and generate API token for array_admin user. Copy API Token.

This API token will be referenced in the purefa_user ansible module to create an ansible service account user and a corresponding storage_admin API token.

8. Create an Ansible User and Storage Admin API Token using the below "get_api_token.yaml" playbook. The array_admin API Token should be passed as a command line argument as shown below.

ubuntu@ip-172-23-1-201:~$ ansible-playbook get_api_token.yaml -e "fa_url=172.23.2.212 array_admin_api_token=405d4e10-0881-1745-f675-01d1c18ae49e"

PLAY [Create API token for FlashArray] ****************************************************************************************************************************************************************************************************************************************************************************

TASK [Create new user ansible with API token] *********************************************************************************************************************************************************************************************************************************************************************
changed: [cloudblockstore]

TASK [print ansibleuser api_token] ********************************************************************************************************************************************************************************************************************************************************************************
ok: [cloudblockstore] => {
"vault_api_token": {
"changed": true,
"failed": false,
"user_info": {
"user_api": "282c22d8-7f70-d91d-35e2-0f75ca0a167c"
}
}
}

PLAY RECAP ********************************************************************************************************************************************************************************************************************************************************************************************************
cloudblockstore : ok=2 changed=1 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0


9. Store the ansible user API token in ansible vault (encrypted file) for use in subsequent store provisinoing playbooks.

9a. Create a 'secrets.yaml' file and enter a new vault password of your choosing. After the password is entered and confirmed this will open a blank file in the vim editor.

ubuntu@ip-172-23-1-201:~$ ansible-vault create secrets.yaml
new Vault password: ansiblevaultpass
Confirm New Vault password: ansiblevaultpass

9b. In the vim editor, enter the newly created ansible storage_admin API Token generated in Step 4. Use 'vault_api_token' as the variable name like shown below. This variable name is hard-coded in the storage provisioning playbooks but can be modified if a different variable name is required.


---
vault_api_token: "6c357bb3-b92a-dce3-ef61-2aa4188ac8ae"


9c. For unpromted decryption when running playbooks, store the password in a different file in plaintext. In the example below the file 'vault-password-file' contains my secrets.yaml password.

Note: It is very important not to commit your plaintext password file into your version control system. Similarly, protect this file to only the user or group that needs access to the stored password on the file system using access control lists (ACL’s).

ubuntu@ip-172-23-1-201:~$ cat vault-password-file
ansiblevaultpass


10. Here are few examples of how to run a playbook which will decrypt the vault file containing the storage_admin API token

Option 1 - Pass the --vault-id option and incule the <vault file>@<vault password file>. This is useful if you have more than one vault file.

ubuntu@ip-172-23-1-201:~$ ansible-playbook combined_playbook.yaml --vault-id secrets.yaml@vault-password-file -e "fa_url=172.23.2.212 hostname=ansiblenewhost12 volname=ansiblenewvol12"


Option 2 - Pass the --vault-password-file argument which points to the unencrypted password file.

ubuntu@ip-172-23-1-201:~$ ansible-playbook combined_playbook.yaml --vault-password-file vault-password-file -e "fa_url=172.23.2.212 hostname=ansiblenewhost12 volname=ansiblenewvol12"

Note: This works because the vault file is specified as a vars_file within the individual playbooks that require the secret, so the vault secret file is already known.

create_volume playbook snippit:

vars_files:
- ./secrets.yaml


Option 3 - Prompt for the vault password when running the playbook. This option does not require a vault password file but will require user input each time a playbook containing the api token variable is run.

ubuntu@ip-172-23-1-201:~$ ansible-playbook combined_playbook.yaml -e "fa_url=172.23.2.212 hostname=ansiblenewhost13 volname=ansiblenewvol13" --ask-vault-pass



You are new ready to run some ansible playbooks to automate storage provisioning tasks!


