terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.69.0"
    }
  }
  required_version = ">= 1.9.5"
}

provider "aws" {
  region     = "eu-west-2"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_KEY_ID
}

variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_KEY_ID" {}

# Create Security Group for web servers  
resource "aws_security_group" "inventory_sg" {
  name        = "INVENTORY-SG"
  description = "Security Group for web servers"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create AWS EC2 Instance (Web Servers)
resource "aws_instance" "web_node1" {
  ami                    = "ami-0c76bd4bd302b30ec"
  instance_type          = "t2.micro"
  key_name               = "Ans-Auth"
  vpc_security_group_ids = [aws_security_group.inventory_sg.id]
  tags = {
    Name         = "Web-Node-Amazon"
    Time-Created = formatdate("MM DD YYYY hh:mm ZZZ", timestamp())
    Department   = "DevOps Masterclass"
  }
}

resource "aws_instance" "web_node2" {
  ami                    = "ami-091f18e98bc129c4e"
  instance_type          = "t2.micro"
  key_name               = "Ans-Auth"
  vpc_security_group_ids = [aws_security_group.inventory_sg.id]
  tags = {
    Name         = "Web-Node-Ubuntu"
    Time-Created = formatdate("MM DD YYYY hh:mm ZZZ", timestamp())
    Department   = "DevOps Masterclass"
  }
}
# Create AWS EC2 Instance (App Servers)
resource "aws_instance" "app_node1" {
  ami                    = "ami-0c76bd4bd302b30ec"
  instance_type          = "t2.micro"
  key_name               = "Ans-Auth"
  vpc_security_group_ids = [aws_security_group.inventory_sg.id]
  tags = {
    Name         = "App-Node-Amazon"
    Time-Created = formatdate("MM DD YYYY hh:mm ZZZ", timestamp())
    Department   = "DevOps Mastaerclass"
  }
}

resource "aws_instance" "app_node2" {
  ami                    = "ami-091f18e98bc129c4e"
  instance_type          = "t2.micro"
  key_name               = "Ans-Auth"
  vpc_security_group_ids = [aws_security_group.inventory_sg.id]
  tags = {
    Name         = "App-Node-Ubuntu"
    Time-Created = formatdate("MM DD YYYY hh:mm ZZZ", timestamp())
    Department   = "DevOps Masterclass"
  }
}
# Create Ansible Control Node
resource "aws_instance" "control_node" {
  ami           = "ami-0c76bd4bd302b30ec"
  instance_type = "t2.micro"
  key_name      = "SSH-KEY"
  vpc_security_group_ids = [aws_security_group.inventory_sg.id]
  tags = {
    Name = "ANSIBLE-CONTROL-NODE"
  }
}

# Generate Ansible Inventory
resource "null_resource" "generate_inventory" {
  depends_on = [aws_instance.web]

  provisioner "local-exec" {
    command = <<EOF
      # Retrieve instance IPs from Terraform output
      web_nodes_ips=$(terraform output -json frontend_ips | jq -r '.[]')
      app_nodes_ips=$(terraform output -json backend_ips | jq -r '.[]')

      # Create Ansible inventory file
      inventory_file="inventory.ini"
      echo "[web_nodes]" > $inventory_file
      for ip in $web_nodes_ips; do
        echo $ip >> $inventory_file
      done

      echo "[app_nodes]" >> $inventory_file
      for ip in $app_nodes_ips; do
        echo $ip >> $inventory_file
      done
    EOF
  }
}

