provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "ansible_control_node" {
  ami           = "ami-0c76bd4bd302b30ec"
  instance_type = "t2.micro"

  tags = {
    Name = "AnsibleControlNode"
  }
}

resource "aws_instance" "amazon_linux_node" {
  count         = 2
  ami           = "ami-0c76bd4bd302b30ec"  
  instance_type = "t2.micro"

  tags = {
    Name = "AmazonLinuxNode-${count.index + 1}"
  }
}

resource "aws_instance" "ubuntu_node" {
  count         = 2
  ami           = "ami-091f18e98bc129c4e"  
  instance_type = "t2.micro"

  tags = {
    Name = "UbuntuNode-${count.index + 1}"
  }
}

output "ansible_control_node_ip" {
  value = aws_instance.ansible_control_node.public_ip
}

output "amazon_linux_node_ips" {
  value = aws_instance.amazon_linux_node[*].public_ip
}

output "ubuntu_node_ips" {
  value = aws_instance.ubuntu_node[*].public_ip
}

resource "null_resource" "ansible_inventory" {
  provisioner "local-exec" {
    command = <<-EOT
      echo "[ansible_control_node]" > inventory.ini
      echo "${aws_instance.ansible_control_node.public_ip}" >> inventory.ini
      echo "\n[amazon_linux_nodes]" >> inventory.ini
      echo "${join("\n", aws_instance.amazon_linux_node[*].public_ip)}" >> inventory.ini
      echo "\n[ubuntu_nodes]" >> inventory.ini
      echo "${join("\n", aws_instance.ubuntu_node[*].public_ip)}" >> inventory.ini
    EOT
  }
}
