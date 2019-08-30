resource "aws_security_group" "private_subnetsecurity" {
  vpc_id = aws_vpc.vpc_environment.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    security_groups = []
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = -1
    protocol    = "icmp"
    to_port     = -1
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
//resource "aws_security_group_rule" "extra_rule" {
//  security_group_id        = aws_security_group.alb_subnetsecurity.id
//  from_port                = 80
//to_port                  = 80
//protocol                 = "tcp"
//type                     = "egress"
//source_security_group_id = aws_security_group.private_subnetsecurity.id
//}

resource "aws_security_group" "alb_subnetsecurity" {
  vpc_id = aws_vpc.vpc_environment.id

  ingress {
    from_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
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
//resource "aws_security_group" "private_subnetsecurity" {
//  vpc_id = aws_vpc.vpc_environment.id
//  ingress {
//    //cidr_blocks = [aws_vpc.vpc_environment.cidr_block]
//    from_port   = 80
//    protocol    = "tcp"
//    to_port     = 80
//    security_groups = [aws_security_group.alb_subnetsecurity.id]
//  }
//  egress {
//    from_port = 80
//    protocol = "tcp"
//    to_port = 80
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//  tags = {
//    key = "Name"
//    value = "Subnet_instance"
//  }
//
//}
//
//resource "aws_security_group_rule" "extra_rule" {
//  security_group_id        = aws_security_group.alb_subnetsecurity.id
//  from_port                = 80
//to_port                  = 80
//protocol                 = "tcp"
//type                     = "egress"
//source_security_group_id = aws_security_group.private_subnetsecurity.id
//}
//
////resource "aws_security_group" "alb_security" {
////  vpc_id = aws_vpc.vpc_environment.id
////
////  ingress {
////    from_port   = 80
////    cidr_blocks = ["0.0.0.0/0"]
////    protocol    = "tcp"
////    to_port     = 80
////  }
////  ingress {
////    cidr_blocks = ["0.0.0.0/0"]
////    from_port   = 443
////    protocol    = "tcp"
////    to_port     = 443
////  }
////
////  ingress {
////    cidr_blocks = ["0.0.0.0/0"]
////    from_port   = -1
////    protocol    = "icmp"
////    to_port     = -1
////  }
////
////  egress {
////    from_port   = 0
////    to_port     = 0
////    protocol    = "-1"
////    cidr_blocks = ["0.0.0.0/0"]
////  }
////  egress {
////    from_port   = 80
////    to_port     = 80
////    protocol    = "tcp"
////    security_groups = [aws_security_group.private_subnesecurity.id]
////  }
////  lifecycle {
////    ignore_changes = [egress, ingress]
////  }
////}
//
//resource "aws_security_group" "alb_subnetsecurity" {
//  vpc_id = aws_vpc.vpc_environment.id
//
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = 443
//    protocol    = "tcp"
//    to_port     = 443
//  }
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = 80
//    protocol    = "tcp"
//    to_port     = 80
//  }
//
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = -1
//    protocol    = "icmp"
//    to_port     = -1
//  }
//
//  egress {
//        from_port   = 80
//        to_port     = 80
//        protocol    = "tcp"
//        cidr_blocks = ["0.0.0.0/0"]
//      }
//
//  tags = {
//    key = "Name"
//    value = "ALB"
//  }
//}