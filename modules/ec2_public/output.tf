output "instance_public_ip" {
  value = aws_instance.server_instance.public_ip
}