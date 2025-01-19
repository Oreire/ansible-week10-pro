output "web_ips" {
  value = aws_instance.web_nodes[*].public_ip
}

output "java_ips" {
  value = aws_instance.java_nodes[*].public_ip
}
