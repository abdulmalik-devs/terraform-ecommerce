resource "aws_security_group" "instance-sgs" {
  name                      = "${var.sg_name_prefix}"
  description               = "SSH on port 22 and HTTP on port 80"
  vpc_id                    = var.vpc_id

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "allow ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "allow http"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
  }
   ingress {
    description = "allow all IcmpV4"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "allow mongodb port"
    from_port        = 27017
    to_port          = 27017
    protocol         = "tcp"
  }
  
  egress {
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
  }
}