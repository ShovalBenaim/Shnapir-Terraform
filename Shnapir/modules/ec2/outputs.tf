output "app_server_public_ips" {
  value = aws_instance.app_server.*.public_ip
}
