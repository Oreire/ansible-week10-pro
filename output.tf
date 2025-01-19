output "web1_ips" {
  value = aws_instance.web_node1.public_ip
}

output "web2_ips" {
  value = aws_instance.web_node2.public_ip
}
output "app1_ips" {
  value = aws_instance.app_node1.public_ip
}

output "app2_ips" {
  value = aws_instance.app_node2.public_ip
}
