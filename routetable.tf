//internet gateway
resource "aws_internet_gateway" "default_gat" {
  vpc_id = aws_vpc.vpc_environment.id
}
resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.vpc_environment.id
  //depends_on = [aws_vpc.vpc_environment]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_gat.id
  }

  tags = {
    Name = "vpc Routing Table"
  }
}

resource "aws_route_table" "route-private" {
  count = length(split(",", var.availability_zones))
  vpc_id = aws_vpc.vpc_environment.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_gat.id
  }

  tags = {
    Name = "Private Subnet Routing Table"
  }
}

resource "aws_main_route_table_association" "main_table_assoc" {
  vpc_id         = aws_vpc.vpc_environment.id
  route_table_id = aws_route_table.route-public.id
}

resource "aws_route_table_association" "public" {
  count = length(split(",",var.availability_zones))
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.route-public.id
}

resource "aws_route_table_association" "private" {
  count          = length(split(",", var.availability_zones))
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.route-private.*.id[count.index]
}
