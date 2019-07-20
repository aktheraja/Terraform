resource "aws_vpc" "vpc_environment" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    name = "Nikky's VPC"
  }
}

resource "aws_subnet" "public_subnet1" {
  cidr_block              = cidrsubnet(aws_vpc.vpc_environment.cidr_block, 4, 1)
  vpc_id                  = aws_vpc.vpc_environment.id
  availability_zone       = "us-west-2c"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet1" {
  cidr_block        = cidrsubnet(aws_vpc.vpc_environment.cidr_block, 4, 2)
  vpc_id            = aws_vpc.vpc_environment.id
  availability_zone = "us-west-2c"
}

resource "aws_subnet" "public_subnet2" {
  cidr_block              = cidrsubnet(aws_vpc.vpc_environment.cidr_block, 4, 3)
  vpc_id                  = aws_vpc.vpc_environment.id
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet2" {
  cidr_block        = cidrsubnet(aws_vpc.vpc_environment.cidr_block, 4, 4)
  vpc_id            = aws_vpc.vpc_environment.id
  availability_zone = "us-west-2b"
}

resource "aws_security_group" "private_subnesecurity" {
  vpc_id = aws_vpc.vpc_environment.id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
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
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "security" {
  vpc_id = aws_vpc.vpc_environment.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
  }
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
  }
//  ingress {
//    cidr_blocks = ["::/0"]
//    from_port   = 80
//    protocol    = "tcp"
//    to_port     = 80
//  }te
//  ingress {
//    cidr_blocks = ["::/0"]
//    from_port   = 443
//    protocol    = "tcp"
//    to_port     = 443
//  }
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

variable "ami_key_pair_name" {
  default = "MyKP"
}

//internet gateway
resource "aws_internet_gateway" "default_gat" {
  vpc_id = aws_vpc.vpc_environment.id
}

//routing table for public subnets
resource "aws_route_table" "route-public" {
  vpc_id = aws_vpc.vpc_environment.id
//depends_on = [aws_vpc.vpc_environment]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default_gat.id
  }

  tags = {
    Name = "vpc Routing Table-nikky"
  }
}

//routing table for private subnet 1
resource "aws_route_table" "route-private1" {
  vpc_id = aws_vpc.vpc_environment.id
//  depends_on = [aws_subnet.private_subnet1]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_1gate.id
  }

  tags = {
    Name = "Private Subnet 1 Routing Table-nikky"
  }
}

//routing table for private subnet 2
resource "aws_route_table" "route-private2" {
  vpc_id = aws_vpc.vpc_environment.id
//  depends_on = [aws_subnet.private_subnet2]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_1gate.id
  }

  tags = {
    Name = "Private Subnet 2 Routing Table-nikky"
  }
}

resource "aws_main_route_table_association" "main_table_assoc" {
  vpc_id         = aws_vpc.vpc_environment.id
  route_table_id = aws_route_table.route-public.id
}

resource "aws_route_table_association" "subnet1_table_assoc" {
  subnet_id      = aws_subnet.private_subnet1.id
  route_table_id = aws_route_table.route-private1.id
}
resource "aws_route_table_association" "subnet2_table_assoc" {
  subnet_id      = aws_subnet.private_subnet2.id
  route_table_id = aws_route_table.route-private2.id
}

resource "aws_launch_configuration" "autoscale_launch" {
  name_prefix            = "CF2TF-LC2"
  image_id        = "ami-07669fc90e6e6cc47"
//  instance_type   = "t2.nano"
  instance_type   = "t2.small"
//  key_name        = var.ami_key_pair_name
  security_groups = [aws_security_group.security.id]
  enable_monitoring = true
  iam_instance_profile = "arn:aws:iam::632199730033:instance-profile/CodeDeployDemo-EC2-Instance-Profile"
  user_data = file(
    "/Users/yujiacui/Desktop/userdatanikky.sh"
  )
  lifecycle {create_before_destroy = true}
}

resource "aws_autoscaling_group" "autoscale_group_1" {
  name="asg-${aws_launch_configuration.autoscale_launch.name}"
  launch_configuration = aws_launch_configuration.autoscale_launch.id
  vpc_zone_identifier  = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet1.id]
//  load_balancers = [aws_alb.alb.name]
//  enabled_metrics = []
  //	load_balancers = ["${aws_elb.elb.name}"]
//  min_size = 2
//  max_size = 5
//  desired_capacity = 3
//  wait_for_elb_capacity = 3
  min_size = 2
  max_size = 4
  desired_capacity = 3
  wait_for_elb_capacity = 0
  tag {
    key                 = "Name"
    value               = "auto_scale"
    propagate_at_launch = true
  }
  health_check_grace_period = 300
  health_check_type = "ELB"
  lifecycle {create_before_destroy = true}
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity="1Minute"

}

resource "aws_autoscaling_group" "autoscale_group_green" {
  name="asg-${aws_launch_configuration.autoscale_launch.name}-green"
  launch_configuration = aws_launch_configuration.autoscale_launch.id
  vpc_zone_identifier  = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet1.id]
  //  enabled_metrics = []
  //	load_balancers = ["${aws_elb.elb.name}"]
  min_size = 0
  max_size = 0
  desired_capacity = 0
  wait_for_elb_capacity = 0
  tag {
    key                 = "Name"
    value               = "auto_scale-green"
    propagate_at_launch = true
  }
  health_check_grace_period = 300
  health_check_type = "ELB"

  lifecycle {create_before_destroy = true}
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity="1Minute"

}
//resource "aws_autoscaling_policy" "web_policy_up" {
//  name = "web_policy_up"
//  scaling_adjustment = 1
//  adjustment_type = "ChangeInCapacity"
//  cooldown = 300
//  autoscaling_group_name = "${aws_autoscaling_group.autoscale_group_1.name}"
////  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
//}

//resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
//  alarm_name = "web_cpu_alarm_up"
//  comparison_operator = "GreaterThanOrEqualToThreshold"
//  evaluation_periods = "2"
//  metric_name = "CPUUtilization"
//  namespace = "AWS/EC2"
//  period = "120"
//  statistic = "Average"
//  threshold = "60"
//
//  dimensions = {
//    AutoScalingGroupName = "${aws_autoscaling_group.autoscale_group_1.name}"
////    "${aws_autoscaling_group.web.name}"
//  }
//
//  alarm_description = "This metric monitor EC2 instance CPU utilization"
//  alarm_actions = ["${aws_autoscaling_policy.web_policy_up.arn}"]
//}

resource "aws_alb_target_group" "alb_target_group_1" {
  name     = "alb-target-group2"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_environment.id

  tags = {
    name = "alb_target_group2-nikky"
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
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.id
}
resource "aws_autoscaling_attachment" "alb_autoscale_green" {
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_green.id
}
resource "aws_alb" "alb" {
  name            = "alb2-Nikky-2b"
  subnets         = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]
  security_groups = [aws_security_group.security.id]
  internal        = false
  idle_timeout    = 1
//  enable_deletion_protection = true
  tags = {
    Name = "alb2-nikkky"
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group_1.arn
    type             = "forward"
  }
}




resource "aws_nat_gateway" "nat_2gate" {
  allocation_id = aws_eip.nat_eip2.id
  subnet_id     = aws_subnet.public_subnet2.id

  tags = {
    name = "NATGateWay2-Nikky"
  }
}

resource "aws_nat_gateway" "nat_1gate" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet1.id

  tags = {
    name = "NATGateWay2-Nikky"
  }
}

resource "aws_eip" "nat_eip2" {

  vpc      = true

}
resource "aws_eip" "nat_eip" {

  vpc      = true
}
resource "aws_route_table" "routtable2" {

  vpc_id = aws_vpc.vpc_environment.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_2gate.id
  }
}
/*
resource "aws_cloudwatch_log_metric_filter" "viewer_view_doc_bytes_read" {
  name           = "viewer_view_document_count"
  pattern        = ""
  log_group_name = aws_cloudwatch_log_group.log1.name
  metric_transformation {
    name         = "viewer_view_doc_bytes_read"
    namespace    = "LogMetrics"
    value        = 1
  }
}
resource "aws_cloudwatch_log_group" "log1" {
  name = "Log1"
}*/
//resource "aws_cloudformation_stack" "network" {
//  name = "networking-stack"
//
//  parameters = {
//    VPCCidr = "10.0.0.0/16"
//  }
//
//  template_body = <<STACK
//{
//  "Parameters" : {
//    "VPCCidr" : {
//      "Type" : "String",
//      "Default" : "10.0.0.0/16",
//      "Description" : "Enter the CIDR block for the VPC. Default is 10.0.0.0/16."
//    }
//  },
//  "Resources" : {
//    "myVpc": {
//      "Type" : "AWS::EC2::VPC",
//      "Properties" : {
//        "CidrBlock" : { "Ref" : "VPCCidr" },
//        "Tags" : [
//          {"Key": "Name", "Value": "Primary_CF_VPC"}
//        ]
//      }
//    }
//  }
//}
//STACK
//}
resource "aws_iam_role" "example" {
  name = "example-role-ni"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.example.name
}
resource "aws_codedeploy_app" "example" {
  name = "example-app"
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name              = "${aws_codedeploy_app.example.name}"
  deployment_group_name = "example-group"
  service_role_arn      = "${aws_iam_role.example.arn}"

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  load_balancer_info {
    target_group_info{
      name = aws_alb_target_group.alb_target_group_1.name
    }
  }
  autoscaling_groups = [aws_autoscaling_group.autoscale_group_1.name]
  alarm_configuration {
    alarms  = ["alarm-1"]
    enabled = true
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "STOP_DEPLOYMENT"
      wait_time_in_minutes = 60

    }

    green_fleet_provisioning_option {
      action = "DISCOVER_EXISTING"

    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }
}
//resource "aws_sns_topic" "example" {
//  name = "example-topic"
//}
//trigger_configuration {
//  trigger_events     = ["InstanceSuccess"]
//  trigger_name       = "example-trigger"
//  trigger_target_arn = "${aws_sns_topic.example.arn}"
//}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bucket-nikky"
  acl    = "private"

  versioning {
    enabled = true
  }
}