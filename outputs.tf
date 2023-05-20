output "client_admin_ip" {
  description = "Public Ip Address of Client-Admin Instance"
  value = module.ec2_client_admin.instance_public_ip
}

output "server-ip" {
  description = "Public Ip Address of Server Instance"
  value = module.ec2_backend.instance_private_ip
}

output "database-ip" {
  description = "Public Ip Address of Database Instance"
  value = module.ec2_database.instance_private_ip
}