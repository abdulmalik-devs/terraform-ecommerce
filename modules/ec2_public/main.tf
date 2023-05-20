resource "aws_instance" "server_instance" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  key_name      = "web"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = "${var.security_group_id}"

  tags = {
    Name = "${var.instance_name}"
  }
}