resource "aws_vpc" "environment-example-two" {
	cidr_block= "10.0.0.0/16"
	enable_dns_hostnames = true
	enable_dns_support = true
	tags{Name = "terraform-aws-vpc-two"}
}
resource "aws_subnet" "subnet1" {
cidr_block = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block,3,1)}"
	vpc_id = "${aws_vpc.environment-example-two.id}"
	availability_zone = "us-east-1a"
	map_public_ip_on_launch = true
	depends_on = ["aws_internet_gateway.default"]

}
resource "aws_subnet" "subnet2" {
	cidr_block = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block,2,2)}"
	vpc_id = "${aws_vpc.environment-example-two.id}"
	availability_zone = "us-east-1b"
}


resource "aws_security_group" "subnetsecurity" {
	vpc_id = "${aws_vpc.environment-example-two.id}"
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

data "aws_ami" "ubuntu" {
	most_recent = true
	filter {
		name = "name"
		values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]

	}
	filter {
		name = "virtualization-type"
		values= ["hvm"]
	}
	owners = ["099720109477"]
}

//resource "aws_key_pair" "my" {
//	key_name   = "my"
//	public_key = "${file("C:/Users/akfre/Downloads/SSH/MyKP.pub")}" }


//instances
variable "ami_key_pair_name" {}
/*
resource "aws_instance" "my-instance" {
	ami = "ami-04169656fea786776"
	count = "${var.instance_count}"
	instance_type = "t2.micro"
//	key_name = "${aws_key_pair.my.key_name}"
//	user_data = "${file("C:/Users/akfre/OneDrive/Documents/terraform bash/install_apache2.sh")}"
	security_groups = ["${aws_security_group.subnetsecurity.id}"]
	subnet_id = "${aws_subnet.subnet1.id}"
//	key_name = "${var.ami_key_pair_name}"
tags = {
Name = "Terraform"
}

}*/
variable "instance_count" {
	default = "1"
}

//internet gateway
resource "aws_internet_gateway" "default" {
	vpc_id = "${aws_vpc.environment-example-two.id}"
}

//routing table for pubic subnet
resource "aws_route_table" "eu-west-1a-public" {
	vpc_id = "${aws_vpc.environment-example-two.id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.default.id}"
	}

	tags {
		Name = "Public Subnet Routing Table"
	}
}
//route table association
resource "aws_route_table_association" "eu-west-1a-public" {
	subnet_id = "${aws_subnet.subnet1.id}"
	route_table_id = "${aws_route_table.eu-west-1a-public.id}"
}
/*
resource "aws_eip" "nat" {
	instance = "${aws_instance.my-instance.id}"
	vpc = true
}*/

//

resource "aws_launch_configuration" "autoscale_launch" {
	name                 = "CF2TF-LC"
	image_id             = "ami-14c5486b"
	instance_type        = "t2.micro"
	key_name              = "${var.ami_key_pair_name}"
	security_groups      = ["${aws_security_group.subnetsecurity.id}"]
	user_data = "${file("C:/Users/akfre/OneDrive/Documents/install_apache_server.sh")}"

}

resource "aws_autoscaling_group" "autoscale_group" {
	launch_configuration = "${aws_launch_configuration.autoscale_launch.id}"
	vpc_zone_identifier = ["${aws_subnet.subnet1.id}","${aws_subnet.subnet2.id}"]
//	load_balancers = ["${aws_elb.elb.name}"]
	min_size = 3
	max_size = 3
	tag {
		key = "Name"
		value = "auto_scale"
		propagate_at_launch = true
	}
}

resource "aws_autoscaling_attachment" "alb_autoscale" {
	alb_target_group_arn   = "${aws_lb_target_group.alb_target_group.arn}"
	autoscaling_group_name = "${aws_autoscaling_group.autoscale_group.id}"
}

resource "aws_lb_listener" "alb_listener" {
	load_balancer_arn = "${aws_lb.alb.arn}"
	port              = 80
	protocol          = "HTTP"

	default_action {
		target_group_arn = "${aws_lb_target_group.alb_target_group.arn}"
		type             = "forward"
	}
}
resource "aws_lb_target_group" "alb_target_group" {
	name     = "alb-target-group"
	port     = "80"
	protocol = "HTTP"
	vpc_id   = "${aws_vpc.environment-example-two.id}"
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

resource "aws_lb" "alb" {
	name            = "alb"
	subnets         = ["${aws_subnet.subnet1.id}","${aws_subnet.subnet2.id}"]
	security_groups = ["${aws_security_group.subnetsecurity.id}"]
	internal        = false
	idle_timeout    = 60
	tags {
		Name    = "alb"
	}
}