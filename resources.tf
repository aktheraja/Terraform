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

}
resource "aws_subnet" "subnet2" {
	cidr_block = "${cidrsubnet(aws_vpc.environment-example-two.cidr_block,2,2)}"
	vpc_id = "${aws_vpc.environment-example-two.id}"
	availability_zone = "us-east-1b"
}


resource "aws_security_group" "subnetsecurity" {
	vpc_id = "${aws_vpc.environment-example-two.id}"
	ingress {
		cidr_blocks = ["${aws_vpc.environment-example-two.cidr_block}"]
		from_port = 80
		protocol = "tcp"
		to_port = 80
	}
	ingress {
		cidr_blocks = ["${aws_vpc.environment-example-two.cidr_block}"]
		from_port = 22
		protocol = "tcp"
		to_port = 22
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

resource "aws_key_pair" "my" {
	key_name   = "my"
	public_key = "${file("C:/Users/akfre/Downloads/SSH/my.pub")}"
}

resource "aws_instance" "my-instance" {
	ami = "ami-04169656fea786776"
	count = "${var.instance_count}"
	instance_type = "t2.micro"
	key_name = "${aws_key_pair.my.key_name}"
	user_data = "${file("C:/Users/akfre/OneDrive/Documents/terraform bash/install_apache.sh")}"
tags = {
Name = "Terraform"
Batch = "5AM"
}
}
variable "instance_count" {
	default = "3"
}


