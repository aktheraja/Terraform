resource "aws_vpc" "vpc_environment" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

//resource "aws_subnet" "public_subnet" {
//  count = length(split(",",var.availability_zones))
//  vpc_id                  = aws_vpc.vpc_environment.id
//  availability_zone = split(",",var.availability_zones)[count.index]
//  cidr_block        = cidrsubnet(signum(length(aws_vpc.vpc_environment.cidr_block)) == 1 ? aws_vpc.vpc_environment.cidr_block : aws_vpc.vpc_environment.cidr_block, ceil(log(length(var.availability_zones) * 2, 2)), length(var.availability_zones) + count.index)
//  map_public_ip_on_launch = true
//}

//routing table for public subnets
//resource "aws_route_table" "route-public" {
//  vpc_id = aws_vpc.vpc_environment.id
//  //depends_on = [aws_vpc.vpc_environment]
//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_internet_gateway.default_gat.id
//  }
//
//  tags = {
//    Name = "vpc Routing Table"
//  }
//}
//
//resource "aws_main_route_table_association" "main_table_assoc" {
//  vpc_id         = aws_vpc.vpc_environment.id
//  route_table_id = aws_route_table.route-public.id
//}
//
//resource "aws_route_table_association" "subnet1_table_assoc" {
//  count = length(split(",",var.availability_zones))
//  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
//  route_table_id = aws_route_table.route-public.id
//}

////private subnets
//resource "aws_subnet" "private_subnet" {
//  count = length(split(",",var.availability_zones))
//  vpc_id                  = aws_vpc.vpc_environment.id
//  cidr_block        = cidrsubnet(signum(length(aws_vpc.vpc_environment.cidr_block)) == 1 ? aws_vpc.vpc_environment.cidr_block: aws_vpc.vpc_environment.cidr_block, ceil(log(length(var.availability_zones) * 2, 2)), count.index)
//  availability_zone = split(",",var.availability_zones)[count.index]
//  map_public_ip_on_launch = true
//  // not sure if we need this line
//  depends_on = ["aws_internet_gateway.default_gat"]
//}

//resource "aws_route_table_association" "private" {
//  count          = length(split(",", var.availability_zones))
//  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
//  route_table_id = aws_route_table.route-private1.*.id[count.index]
//}

//
//resource "aws_security_group" "private_subnesecurity" {
//  vpc_id = aws_vpc.vpc_environment.id
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = 80
//    protocol    = "tcp"
//    to_port     = 80
//  }
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = 22
//    protocol    = "tcp"
//    to_port     = 22
//  }
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = -1
//    protocol    = "icmp"
//    to_port     = -1
//  }
//
//  egress {
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//}
//
//resource "aws_security_group" "security" {
//  vpc_id = aws_vpc.vpc_environment.id
//
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = 80
//    protocol    = "tcp"
//    to_port     = 80
//  }
//  ingress {
//    cidr_blocks = ["0.0.0.0/0"]
//    from_port   = 443
//    protocol    = "tcp"
//    to_port     = 443
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
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = ["0.0.0.0/0"]
//  }
//}

//variable "ami_key_pair_name" {
//  default = "MyKP"
//}

////internet gateway
//resource "aws_internet_gateway" "default_gat" {
//  vpc_id = aws_vpc.vpc_environment.id
//}



//routing table for private subnet 1
//resource "aws_route_table" "route-private1" {
//  count = length(split(",", var.availability_zones))
//  vpc_id = aws_vpc.vpc_environment.id
//  route {
//    cidr_block = "0.0.0.0/0"
//    gateway_id = aws_internet_gateway.default_gat.id
//  }
//
//  tags = {
//    Name = "Private Subnet 1 Routing Table"
//  }
//}

//variable "ami" {
//
//  default = "ami-07669fc90e6e6cc47"
//}
//resource "aws_launch_configuration" "autoscale_launch_config" {
//  name_prefix          = "autoscale_launcher-nikky-"
//  image_id        = var.ami
//  instance_type   = "t2.nano"
////  key_name        = var.ami_key_pair_name
//  security_groups = [aws_security_group.security.id]
//  enable_monitoring = true
//  user_data = file(
//    "/Users/yujiacui/Desktop/install_apache_server.sh"
//
//  )
//  lifecycle {create_before_destroy = true}
//}




//resource "aws_autoscaling_group" "autoscale_group_1" {
//  name="asg-${aws_launch_configuration.autoscale_launch_config.name}"
//  launch_configuration = aws_launch_configuration.autoscale_launch_config.id
////  vpc_zone_identifier  = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet1.id]
//  vpc_zone_identifier  = aws_subnet.public_subnet.*.id
//  min_size = var.min_asg
//  max_size = var.max_asg
//  desired_capacity = var.des_asg
//  wait_for_elb_capacity = 3
//
//  tag {
//    key                 = "Name"
//    value               = "auto_scale-Nikky"
//    propagate_at_launch = true
//  }
//
//  health_check_grace_period = 200
//  health_check_type = "ELB"
//  //load_balancers = [aws_alb.alb.name]
//  lifecycle {create_before_destroy = true}
//  enabled_metrics = [
//
//    "GroupInServiceInstances",
//    "GroupTotalInstances"
//
//  ]
//  //depends_on = [data.aws_autoscaling_group.autoscale_group_1]
//  metrics_granularity="1Minute"
//provisioner "local-exec" {
//  command = "check_health.sh ${aws_alb.alb.dns_name} asg-autoscale_launcher-nikky-20190724010048552300000001 aws_alb_target_group.alb_target_group_1.arn"
//}
//}
//
//  locals {
//  ASGname=aws_autoscaling_group.autoscale_group_1.name
//}


//resource "aws_alb_target_group" "alb_target_group_1" {
//  name_prefix    = "targp-"
//  port     = "80"
//  protocol = "HTTP"
//  vpc_id   = aws_vpc.vpc_environment.id
//  tags = {
//    name = "alb_target_group"
//  }
//  stickiness {
//    type            = "lb_cookie"
//    cookie_duration = 1800
//    enabled         = true
//  }
//  slow_start = 0
//  deregistration_delay = 30
//  health_check {
//    healthy_threshold   = 3
//    unhealthy_threshold = 3
//    timeout             = 2
//    interval            = 15
//    path                = "/"
//    port                = 80
//  }
//  lifecycle {create_before_destroy = true}
//}

//resource "aws_autoscaling_attachment" "alb_autoscale" {
//  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
//  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.id
//  lifecycle {create_before_destroy = true}
//  provisioner "local-exec" {
//    command = "attchmnt_checkhealth.sh asg-autoscale_launcher-nikky-20190725064518336300000001 ${aws_alb_target_group.alb_target_group_1.arn}"
//  }
//
//}

//resource "aws_alb" "alb" {
//  name_prefix = "lbCrg-"
//  subnets =aws_subnet.public_subnet.*.id
//  security_groups = [
//    aws_security_group.security.id]
//  internal = false
//  idle_timeout = 2
//  tags = {
//    Name = "alb2"
//  }
//  lifecycle {create_before_destroy = true}
//}
//
//resource "aws_alb_listener" "alb_listener" {
//  load_balancer_arn = aws_alb.alb.arn
//  port              = 80
//  protocol          = "HTTP"
//  default_action {
//    target_group_arn = aws_alb_target_group.alb_target_group_1.arn
//    type             = "forward"
//  }
//  lifecycle {create_before_destroy = true}
//}


//resource "aws_eip" "nat_eip" {
//  count = length(split(",", var.availability_zones))
//  vpc      = true
//  lifecycle {
//    create_before_destroy = true
//  }
//}


//resource "aws_nat_gateway" "nat_gate" {
//
//  count  = length(split(",", var.availability_zones))
//
//  allocation_id = aws_eip.nat_eip.*.id[count.index]
//  subnet_id = aws_subnet.public_subnet.*.id[count.index]
//  lifecycle {
//    create_before_destroy = true
//  }
//}

