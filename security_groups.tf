resource "aws_security_group" "alb_subnetsecurity" {
  vpc_id = aws_vpc.vpc_environment.id

  lifecycle {create_before_destroy = true}
  tags = {
    Name = "alb"
  }
}
resource "aws_security_group" "private_subnetsecurity" {
  vpc_id = aws_vpc.vpc_environment.id
  lifecycle {create_before_destroy = true}
  tags = {
Name = "instance"
  }
}

//===================================================================
//Instance security group rules
//===================================================================

resource "aws_security_group_rule" "ingress_for_instance" {
  security_group_id        = aws_security_group.private_subnetsecurity.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = aws_security_group.alb_subnetsecurity.id
  lifecycle {create_before_destroy = true}
}

resource "aws_security_group_rule" "egress_for_instance" {
  security_group_id        = aws_security_group.private_subnetsecurity.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "egress"
  //source_security_group_id = aws_security_group.alb_subnetsecurity.id
  cidr_blocks = ["0.0.0.0/0"]
  lifecycle {create_before_destroy = true}
}



//===================================================================
//ALB security group rules
//===================================================================

resource "aws_security_group_rule" "egress_for_alb_to_instance" {
  security_group_id        = aws_security_group.alb_subnetsecurity.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "egress"
  source_security_group_id = aws_security_group.private_subnetsecurity.id
  lifecycle {create_before_destroy = true}
}

resource "aws_security_group_rule" "ingress_for_alb_http" {
  security_group_id        = aws_security_group.alb_subnetsecurity.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  lifecycle {create_before_destroy = true}
}
resource "aws_security_group_rule" "ingress_for_alb_https" {
  security_group_id        = aws_security_group.alb_subnetsecurity.id
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  type                     = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  lifecycle {create_before_destroy = true}
}
resource "aws_security_group_rule" "ingress_for_alb_icmp" {
  security_group_id        = aws_security_group.alb_subnetsecurity.id
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  type                     = "ingress"
  cidr_blocks = ["0.0.0.0/0"]
  lifecycle {create_before_destroy = true}
}

