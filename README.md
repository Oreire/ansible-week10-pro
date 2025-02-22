# ansible-week10-pro
Configuration Management with Ansible Playbooks

name: Deploy EC2 Instances

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1

      - name: Terraform Init
        run: terraform init

      - name: Terraform Format Check
        run: terraform fmt -check

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Apply
        run: terraform apply -auto-approve

      - name: Generate Ansible Inventory
        run: terraform output -json > tf_output.json

      - name: Install Ansible
        run: sudo apt-get update && sudo apt-get install -y ansible

      - name: Run Ansible Playbook for Frontend
        run: ansible-playbook -i hosts frontend_playbook.yml

      - name: Run Ansible Playbook for Backend
        run: ansible-playbook -i hosts backend_playbook.yml
