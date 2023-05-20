output "vpc-id" {
  value = aws_vpc.devs-vpc.id
}

output "public_subnet_1a" {
  value = aws_subnet.devs-public-1a.id
}

output "public_subnet_1b" {
  value = aws_subnet.devs-public-1b.id
}

output "private_subnet_1c" {
  value = aws_subnet.devs-private-1c.id
}

output "private_subnet_1d" {
  value = aws_subnet.devs-private-1d.id
}



