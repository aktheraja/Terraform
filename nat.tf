resource "aws_nat_gateway" "nat_gate" {
  count  = length(split(",", var.availability_zones))

  allocation_id = aws_eip.nat_eip.*.id[count.index]
  subnet_id = aws_subnet.public_subnet.*.id[count.index]
  lifecycle {
    create_before_destroy = true
  }
}
//
