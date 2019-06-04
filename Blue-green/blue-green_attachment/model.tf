
resource "aws_vpc" "environment-example-two" {
  cidr_block= "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {Name = "terraform-aws-vpc-two"}
}
resource "aws_subnet" "public_subnet1" {
  cidr_block = cidrsubnet(aws_vpc.environment-example-two.cidr_block,3,1)
  vpc_id = aws_vpc.environment-example-two.id
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  depends_on = ["aws_internet_gateway.default"]

}
resource "aws_subnet" "private_subnet1" {
  cidr_block = cidrsubnet(aws_vpc.environment-example-two.cidr_block,2,2)
  vpc_id = aws_vpc.environment-example-two.id
  availability_zone = "us-east-1b"
}

//resource "aws_subnet" "public_subnet2" {
//	cidr_block = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block,3,1)}"
//	vpc_id = "${aws_vpc.environment-example-two.id}"
//	availability_zone = "us-west-2a"
//	map_public_ip_on_launch = true
//	depends_on = ["aws_internet_gateway.default"]
//
//}
//resource "aws_subnet" "private_subnet2" {
//	cidr_block = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block,2,2)}"
//	vpc_id = "${aws_vpc.environment-example-two.id}"
//	availability_zone = "us-west-2b"
//}



resource "aws_security_group" "subnetsecurity" {
  vpc_id = aws_vpc.environment-example-two.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    protocol = "tcp"
    to_port = 80
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    protocol = "tcp"
    to_port = 22
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = -1
    protocol = "icmp"
    to_port = -1
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "ami_key_pair_name" {}

variable "instance_count" {
  default = "1"
}

//internet gateway
resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.environment-example-two.id
}

//routing table for pubic subnet
resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.environment-example-two.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "Public Subnet Routing Table"
  }
}
//route table association
resource "aws_route_table_association" "route_association_public" {
  subnet_id = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.route-public.id
}


//
resource "aws_launch_configuration" "autoscale_launch" {
  name                 = var.color
  image_id             = "ami-14c5486b"
  instance_type        = "t2.nano"
  key_name              = var.ami_key_pair_name
  security_groups      = [
    aws_security_group.subnetsecurity.id]
  user_data = file("C:/Users/akfre/OneDrive/Documents/install_apache_server.sh")
//  lifecycle {
//    create_before_destroy = true
//  }
}

resource "aws_autoscaling_policy" "up" {
  name                   = "blue-green-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = "600"
  scaling_adjustment = "-1"
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.name
//  lifecycle {
//    create_before_destroy = true
//  }
}

resource "aws_autoscaling_policy" "down" {
  name                   = "blue-green-policy"
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = "600"
  scaling_adjustment = "-1"
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.name
}


resource "aws_autoscaling_group" "autoscale_group_1" {
  name                      = "terraform-asg-${var.color}"
  launch_configuration = aws_launch_configuration.autoscale_launch.id
  vpc_zone_identifier = [
    aws_subnet.public_subnet1.id,
    aws_subnet.private_subnet1.id]
  //	load_balancers = ["${aws_elb.elb.name}"]
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity

  tag {
    key = "Name"
    value = var.color
    propagate_at_launch = true
  }
}
locals {
  asg_name = "${var.name}-${var.color}"
}
resource "aws_lb_target_group" "alb_target_group_1" {
  name     = var.color
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.environment-example-two.id
  tags = {
    name = "alb_target_group"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = true
  }
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 10
    timeout             = 5
    interval            = 10
    path                = "/"
    port                = 80
  }
}

resource "aws_autoscaling_attachment" "alb_autoscale" {
  alb_target_group_arn   = aws_lb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.id
}

resource "aws_lb" "alb" {
  name            = var.color
  subnets         = [
    aws_subnet.public_subnet1.id,
    aws_subnet.private_subnet1.id]
  security_groups = [
    aws_security_group.subnetsecurity.id]
  internal        = false
  idle_timeout    = 60
  tags  = {
    Name    = var.color
  }
}
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_lb_target_group.alb_target_group_1.arn
    type             = "forward"
  }
}







