//routing table for public subnets
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
    nat_gateway_id = aws_nat_gateway.nat_gate.*.id[count.index]
  }
  tags = {
    Name = "Private Subnet Routing Table"
  }
}
resource "aws_route_table_association" "private" {
  count          = length(split(",", var.availability_zones))
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.route-private.*.id[count.index]
}


////routing table for private subnet 1
//resource "aws_route_table" "route-private1" {
//  vpc_id = aws_vpc.vpc_environment.id
//  //  depends_on = [aws_subnet.private_subnet1]
//  route {
//    cidr_block = "0.0.0.0/0"
//    nat_gateway_id = aws_nat_gateway.nat_1gate.id
//  }
//
//  tags = {
//    Name = "Private Subnet 1 Routing Table"
//  }
//}
//
////routing table for private subnet 2
//resource "aws_route_table" "route-private2" {
//  vpc_id = aws_vpc.vpc_environment.id
//
//  route {
//    cidr_block = "0.0.0.0/0"
//    nat_gateway_id = aws_nat_gateway.nat_2gate.id
//  }
//
//  tags = {
//    Name = "Private Subnet 2 Routing Table"
//  }
//}

resource "aws_main_route_table_association" "main_table_assoc" {
  vpc_id         = aws_vpc.vpc_environment.id
  route_table_id = aws_route_table.route-public.id
}

//resource "aws_route_table_association" "subnet1_table_assoc" {
//  subnet_id      = aws_subnet.private_subnet1.id
//  route_table_id = aws_route_table.route-private1.id
//}
//resource "aws_route_table_association" "subnet2_table_assoc" {
//  subnet_id      = aws_subnet.private_subnet2.id
//  route_table_id = aws_route_table.route-private2.id
//}