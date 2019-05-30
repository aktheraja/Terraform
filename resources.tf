resource "aws_vpc" "vpc_environment" {
	cidr_block= "10.0.0.0/16"
	enable_dns_hostnames = true
	enable_dns_support = true
	tags{Name = "terraform-aws-vpc"}
}
resource "aws_subnet" "public_subnet1" {
cidr_block = "${cidrsubnet(aws_vpc.vpc_environment.cidr_block,3,1)}"
	vpc_id = "${aws_vpc.vpc_environment.id}"
	availability_zone = "us-west-2"
	map_public_ip_on_launch = true
	depends_on = ["aws_internet_gateway.default"]

}
resource "aws_subnet" "private_subnet1" {
	cidr_block = "${cidrsubnet(aws_vpc.vpc_environment.cidr_block,2,2)}"
	vpc_id = "${aws_vpc.vpc_environment.id}"
	availability_zone = "us-west-2"
}

resource "aws_subnet" "public_subnet2" {
	cidr_block = "${cidrsubnet(aws_vpc.vpc_environment.cidr_block,3,1)}"
	vpc_id = "${aws_vpc.vpc_environment.id}"
	availability_zone = "us-east-1a"
	map_public_ip_on_launch = true
	depends_on = ["aws_internet_gateway.default"]

}
resource "aws_subnet" "private_subnet2" {
	cidr_block = "${cidrsubnet(aws_vpc.vpc_environment.cidr_block,2,2)}"
	vpc_id = "${aws_vpc.vpc_environment.id}"
	availability_zone = "us-east-1a"
}



resource "aws_security_group" "private_subnetsecurity" {
	vpc_id = "${aws_vpc.vpc_environment.id}"
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

resource "aws_security_group" "public_subnetsecurity" {
	vpc_id = "${aws_vpc.vpc_environment.id}"
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



//internet gateway
resource "aws_internet_gateway" "default" {
	vpc_id = "${aws_vpc.vpc_environment.id}"
}

//routing table for pubic subnet
resource "aws_route_table" "route-public" {
	vpc_id = "${aws_vpc.vpc_environment.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}

	tags {
		Name = "Public Subnet Routing Table"
	}
}
//route table association
resource "aws_route_table_association" "route_association_public" {
	subnet_id = "${aws_subnet.public_subnet1.id}"
	route_table_id = "${aws_route_table.route-public.id}"
}


//
resource "aws_launch_configuration" "autoscale_launch" {
	name                 = "CF2TF-LC"
	image_id             = "ami-14c5486b"
	instance_type        = "t2.nano"
	key_name              = "${var.ami_key_pair_name}"
	security_groups      = ["${aws_security_group.subnetsecurity.id}"]
	user_data = "${file("C:/Users/Default.Default-PC/Downloads/install_apache_server.sh")}"
}

resource "aws_autoscaling_group" "autoscale_group_1" {
	launch_configuration = "${aws_launch_configuration.autoscale_launch.id}"
	vpc_zone_identifier = ["${aws_subnet.public_subnet1.id}","${aws_subnet.private_subnet1.id}"]
//	load_balancers = ["${aws_elb.elb.name}"]
	min_size = 3
	max_size = 3
	tag {
		key = "Name"
		value = "auto_scale"
		propagate_at_launch = true
	}
}

resource "aws_lb_target_group" "alb_target_group_1" {
	name     = "alb-target-group"
	port     = "80"
	protocol = "HTTP"
	vpc_id   = "${aws_vpc.vpc_environment.id}"
	tags {
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
	alb_target_group_arn   = "${aws_lb_target_group.alb_target_group_1.arn}"
	autoscaling_group_name = "${aws_autoscaling_group.autoscale_group_1.id}"
}

resource "aws_lb" "alb" {
	name            = "alb"
	subnets         = ["${aws_subnet.public_subnet1.id}","${aws_subnet.private_subnet1.id}"]
	security_groups = ["${aws_security_group.subnetsecurity.id}"]
	internal        = false
	idle_timeout    = 60
	tags {
		Name    = "alb"
	}
}
resource "aws_lb_listener" "alb_listener" {
	load_balancer_arn = "${aws_lb.alb.arn}"
	port              = 80
	protocol          = "HTTP"
	default_action {
		target_group_arn = "${aws_lb_target_group.alb_target_group_1.arn}"
		type             = "forward"
	}
}













resource "aws_autoscaling_group" "autoscale_group_2" {
	launch_configuration = "${aws_launch_configuration.autoscale_launch.id}"
	vpc_zone_identifier = ["${aws_subnet.public_subnet2.id}","${aws_subnet.private_subnet2.id}"]
	//	load_balancers = ["${aws_elb.elb.name}"]
	min_size = 3
	max_size = 3
	tag {
		key = "Name"
		value = "auto_scale"
		propagate_at_launch = true
	}
}

resource "aws_lb_target_group" "alb_target_group_2" {
	name     = "alb-target-group"
	port     = "80"
	protocol = "HTTP"
	vpc_id   = "${aws_vpc.vpc_environment.id}"
	tags {
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

resource "aws_autoscaling_attachment" "alb_autoscale_2" {
	alb_target_group_arn   = "${aws_lb_target_group.alb_target_group_2.arn}"
	autoscaling_group_name = "${aws_autoscaling_group.autoscale_group_2.id}"
}

resource "aws_lb" "alb_2" {
	name            = "alb"
	subnets         = ["${aws_subnet.public_subnet2.id}","${aws_subnet.private_subnet2.id}"]
	security_groups = ["${aws_security_group.subnetsecurity.id}"]
	internal        = false
	idle_timeout    = 60
	tags {
		Name    = "alb"
	}
}
resource "aws_lb_listener" "alb_listener_2" {
	load_balancer_arn = "${aws_lb.alb_2.arn}"
	port              = 80
	protocol          = "HTTP"
	default_action {
		target_group_arn = "${aws_lb_target_group.alb_target_group_2.arn}"
		type             = "forward"
	}
}
resource "aws_nat_gateway" "nat_gate" {
	allocation_id = ""
	subnet_id = ""
}
resource "aws_eip" "nat" {
	vpc =  true

	instance = "${aws_launch_configuration.autoscale_launch.image_id}"
	depends_on = ["aws_internet_gateway.default"]


}