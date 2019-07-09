#========================== TEST VPC =============================

# Declare the data source
data "aws_availability_zones" "available" {}


# Define a vpc
resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
//  cidr_block = var.test_network_cidr
  tags = {
    Name = var.test_vpc
  }
}

# Internet gateway for the public subnet
resource "aws_internet_gateway" "test_ig" {
  vpc_id = aws_vpc.test_vpc.id
  tags = {
    Name = "test_ig"
  }
}

# Public subnets
resource "aws_subnet" "public_sn" {
  vpc_id = aws_vpc.test_vpc.id
  count =var.az_count
  cidr_block  = cidrsubnet(aws_vpc.test_vpc.cidr_block, count*2, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_Subnet ${count.index}"
  }
}

# Private subnets
resource "aws_subnet" "private_sn" {
  vpc_id = aws_vpc.test_vpc.id
  count =var.az_count
  cidr_block  = cidrsubnet(aws_vpc.test_vpc.cidr_block, count*2, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "Private_Subnet ${count.index}"
  }
}


# Routing table for VPC
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_ig.id
  }
  tags = {
    Name = "VPC Route Table"
  }
}

# Set the routing table as main for the VPC
resource "aws_main_route_table_association" "main_table_assoc" {
  vpc_id         = aws_vpc.test_vpc.id
  route_table_id = aws_route_table.public_rt.id
}

# Routing tables for private subnets
resource "aws_route_table" "private_rt" {
  count = var.az_count
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gate.id
  }

  tags = {
    Name = "Private Subnet ${count.index} Routing Table"
  }
}

# Associate routing tables to private subnets
resource "aws_route_table_association" "test_public_sn_rt_assn_02" {
  count = var.az_count
  subnet_id = aws_subnet.private_sn.id
  route_table_id = aws_route_table.private_rt.id
}

# NAT gateways
resource "aws_nat_gateway" "nat_gate" {
  count=var.az_count
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_sn.id
  lifecycle {
    create_before_destroy = true
  }
}

# NAT EIPs
resource "aws_eip" "nat_eip" {
  count =var.az_count
  vpc = true
  lifecycle {
    create_before_destroy = true
  }
}

# ECS Instance Security group
resource "aws_security_group" "public_sg" {
  name = "test_public_sg"
  description = "Test public access security group"
  vpc_id = aws_vpc.test_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    cidr_blocks = [
      var.test_public_01_cidr,
      var.test_public_02_cidr]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port = "0"
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags ={
    Name = "test_public_sg"
  }
}

resource "aws_security_group" "alb_security" {
  vpc_id = aws_vpc.test_vpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = -1
    protocol    = "icmp"
    to_port     = -1
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
