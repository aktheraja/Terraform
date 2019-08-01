resource "aws_eip" "nat_eip" {
  count = length(split(",", var.availability_zones))
  vpc      = true
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    name = "eip-nikky"
  }
}