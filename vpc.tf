resource "aws_vpc" "vpc_environment" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags ={
    name = "NikVPC"

  }
}

resource "aws_internet_gateway" "default_gat" {
  vpc_id = aws_vpc.vpc_environment.id
}

//resource "aws_subnet" "public_subnet1" {
//  cidr_block              = cidrsubnet(aws_vpc.vpc_environment.cidr_block, 4, 1)
//  vpc_id                  = aws_vpc.vpc_environment.id
//  availability_zone       = "us-west-2c"
//  map_public_ip_on_launch = true
//}
//
//resource "aws_subnet" "private_subnet1" {
//  cidr_block        = cidrsubnet(aws_vpc.vpc_environment.cidr_block, 4, 2)
//  vpc_id            = aws_vpc.vpc_environment.id
//  availability_zone = "us-west-2c"
//}
resource "aws_subnet" "public_subnet" {
  count = length(split(",",var.availability_zones))
  cidr_block              = cidrsubnet(signum(length(aws_vpc.vpc_environment.cidr_block)) == 1 ? aws_vpc.vpc_environment.cidr_block : aws_vpc.vpc_environment.cidr_block, ceil(log(length(var.availability_zones) * 2, 2)), length(var.availability_zones) + count.index)
  vpc_id                  = aws_vpc.vpc_environment.id
  availability_zone       = split(",",var.availability_zones)[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name    = "public subnet-nik${count.index}"
  }
}

//resource "aws_subnet" "public_subnet2" {
//  cidr_block              = cidrsubnet(aws_vpc.vpc_environment.cidr_block, 4, 3)
//  vpc_id                  = aws_vpc.vpc_environment.id
//  availability_zone       = "us-west-2b"
//  map_public_ip_on_launch = true
//}
//
//resource "aws_subnet" "private_subnet2" {
//  cidr_block        = cidrsubnet(aws_vpc.vpc_environment.cidr_block, 4, 4)
//  vpc_id            = aws_vpc.vpc_environment.id
//  availability_zone = "us-west-2b"
//}
resource "aws_subnet" "private_subnet" {
  count = length(split(",",var.availability_zones))
  vpc_id                  = aws_vpc.vpc_environment.id
  cidr_block        = cidrsubnet(signum(length(aws_vpc.vpc_environment.cidr_block)) == 1 ? aws_vpc.vpc_environment.cidr_block: aws_vpc.vpc_environment.cidr_block, ceil(log(length(var.availability_zones) * 2, 2)), count.index)
  availability_zone = split(",",var.availability_zones)[count.index]
  tags = {
    Name    = "private subnet-nik${count.index}"
  }
}