resource "aws_subnet" "public_subnet" {
  count = length(split(",",var.availability_zones))
  vpc_id                  = aws_vpc.vpc_environment.id
  availability_zone = split(",",var.availability_zones)[count.index]
  cidr_block        = cidrsubnet(signum(length(aws_vpc.vpc_environment.cidr_block)) == 1 ? aws_vpc.vpc_environment.cidr_block : aws_vpc.vpc_environment.cidr_block, ceil(log(length(var.availability_zones) * 2, 2)), length(var.availability_zones) + count.index)
  map_public_ip_on_launch = true
  tags = {
    Name    = "public subnet${count.index}"
  }
}

//private subnets
resource "aws_subnet" "private_subnet" {
  count = length(split(",",var.availability_zones))
  vpc_id                  = aws_vpc.vpc_environment.id
  cidr_block        = cidrsubnet(signum(length(aws_vpc.vpc_environment.cidr_block)) == 1 ? aws_vpc.vpc_environment.cidr_block: aws_vpc.vpc_environment.cidr_block, ceil(log(length(var.availability_zones) * 2, 2)), count.index)
  availability_zone = split(",",var.availability_zones)[count.index]
//  map_public_ip_on_launch = true
  // not sure if we need this line
  depends_on = ["aws_internet_gateway.default_gat"]
  tags = {
    Name    = "private subnet${count.index}"
  }
}

//
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "my-dashboard"

  dashboard_body = <<EOF
 {
   "widgets": [
       {
          "type":"metric",
          "x":0,
          "y":0,
          "width":12,
          "height":6,
          "properties":{
             "metrics":[
                [
                   "AWS/AutoScaling",
                   "GroupInServiceInstances",
                   "AutoScalingGroupName",
                   "asg-autoscale_launcher-nikky-2019080216113616390000000520190802161136902800000006"
                ]
             ],
             "period":300,
             "stat":"Average",
             "region":"us-west-2",
             "title":"Instances In Service"
          }
       },
       {
          "type":"text",
          "x":0,
          "y":7,
          "width":3,
          "height":3,
          "properties":{
             "markdown":"Hello world"
          }
       }
   ]
 }
 EOF
}

