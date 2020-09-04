resource "aws_instance" "ubuntu17" {
  ami = "ami-0ba60995c1589da9d"
  instance_type = "t2.micro"
  key_name = "badger"
  vpc_security_group_ids = ["sg-01e66868b90f12678",]
  subnet_id = "subnet-0d73bf0c3cf9e8263"
  user_data = <<-EOF
              #! /bin/bash
              apt update
              apt install software-properties-common -y
              apt-add-repository --yes --update ppa:ansible/ansible
              apt install ansible -y
              EOF

  provisioner "remote-exec" {
    inline = [
      "echo 'Waiting for SSH'",
    ]

    connection {
      host        = self.private_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_path)
    }
  }

  provisioner "local-exec" {

    working_dir = "../ansible/"
    command = "ansible-playbook -i '${self.private_ip},' -i 'cloudblockstore,' --private-key ${var.private_key_path} -e 'cloud_initiator='${self.private_ip}' fa_url=172.23.2.212 volname=purevol223 size=1T pure_api_token=95655d27-b540-37c3-919c-e96018bb37ff ansible_python_interpreter=/usr/bin/python3' combined_playbook.yaml"
  }
}
