output "web_ips" {
  value = aws_instance.web_nodes[*].public_ip
}

output "app_ips" {
  value = aws_instance.app_nodes[*].public_ip
}
