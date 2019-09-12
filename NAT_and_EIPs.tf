//resource "aws_nat_gateway" "nat_2gate" {
//  allocation_id = aws_eip.nat_eip2.id
//  subnet_id     = aws_subnet.public_subnet2.id
//  lifecycle {
//    create_before_destroy = true
//  }
//}
//
//resource "aws_nat_gateway" "nat_1gate" {
//  allocation_id = aws_eip.nat_eip.id
//  subnet_id     = aws_subnet.public_subnet1.id
//  lifecycle {
//    create_before_destroy = true
//  }
//}
//
//resource "aws_eip" "nat_eip2" {
//
//  vpc      = true
//  lifecycle {
//    create_before_destroy = true
//  }
//}
//resource "aws_eip" "nat_eip" {
//
//  vpc      = true
//  lifecycle {
//    create_before_destroy = true
//  }
//}

resource "aws_nat_gateway" "nat_gate" {

  count  = length(split(",", var.availability_zones))

  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id = aws_subnet.public_subnet.*.id[count.index]
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_eip" "nat_eip" {
  count = length(split(",", var.availability_zones))
  vpc      = true
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    name = "eip-${var.deployment_name}"
  }
}