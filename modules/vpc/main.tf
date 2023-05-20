# Creating VPC, Name, CIDR amd Tags
resource "aws_vpc" "devs-vpc" {
  cidr_block                = "10.0.0.0/16"
  instance_tenancy          = "default"
  enable_dns_hostnames      = "true"
  enable_dns_support        = "true"
  enable_classiclink        = "false"

  tags = {
    Name = "${var.vpc_name}"
  }
}

# Creating Public Subnet in VPC
resource "aws_subnet" "devs-public-1a" {
  vpc_id                    = aws_vpc.devs-vpc.id
  cidr_block                = "10.0.1.0/24"
  map_public_ip_on_launch   = "true"
  availability_zone         = "us-east-1a"

  tags = {
    Name = "devs-public-1a"
  }
}

resource "aws_subnet" "devs-public-1b" {
  vpc_id                    = aws_vpc.devs-vpc.id
  cidr_block                = "10.0.2.0/24"
  map_public_ip_on_launch   = "true"
  availability_zone         = "us-east-1b"

  tags = {
    Name = "devs-public-1b"
  }
}

# Creating Private Subnets in VPC
resource "aws_subnet" "devs-private-1c" {
  vpc_id                  = aws_vpc.devs-vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1c"

  tags = {
    Name = "dev-private-1c"
  }
}

resource "aws_subnet" "devs-private-1d" {
  vpc_id                  = aws_vpc.devs-vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1d"

  tags = {
    Name = "dev-private-1d"
  }
}


# Creating Internet Gateway in AWS VPC
resource "aws_internet_gateway" "igw" {
  vpc_id  = aws_vpc.devs-vpc.id

  tags = {
    Name  = "devs"
  }
}

# Creating Route Tables for Internet gateway
resource "aws_route_table" "route-igw" {
  vpc_id            = aws_vpc.devs-vpc.id
  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Route-IGW"
  }
}

# Creating Route Associations public subnets
resource "aws_route_table_association" "devs-public-1" {
  subnet_id          = aws_subnet.devs-public-1a.id
  route_table_id     = aws_route_table.route-igw.id
}

resource "aws_route_table_association" "devs-public-2" {
  subnet_id          = aws_subnet.devs-public-1b.id
  route_table_id     = aws_route_table.route-igw.id
}

# Creating Nat Gateway
resource "aws_eip" "nat" {
  vpc = true
}

# Attachning Nat Gateway to Public Subnet
resource "aws_nat_gateway" "nat-igw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.devs-public-1a.id
  depends_on    = [aws_internet_gateway.igw]
}

# Add routes for private subnets 
resource "aws_route_table" "route-nat" {
  vpc_id = aws_vpc.devs-vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-igw.id
  }
  tags = {
    Name = "route-nat"
  }
}

# Creating route associations for private Subnets
resource "aws_route_table_association" "dev-private-1" {
  subnet_id      = aws_subnet.devs-private-1c.id
  route_table_id = aws_route_table.route-nat.id
}

resource "aws_route_table_association" "dev-private-2" {
  subnet_id      = aws_subnet.devs-private-1d.id
  route_table_id = aws_route_table.route-nat.id
}
