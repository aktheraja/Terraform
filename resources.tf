

variable "ami_key_pair_name" {
  default = "MyKP"
}


variable "ami" {

  default = "ami-07669fc90e6e6cc47"
}

variable "min_asg" {
  default = 2
}

variable "des_asg" {
  default = 3
}

variable "max_asg" {
  default = 5
}


variable "min_asg2" {
  default = 0
}

variable "des_asg2" {
  default = 0
}

variable "max_asg2" {
  default = 0
}

//
//
//data "aws_autoscaling_group" "autoscale_group_1" {
//  name = aws_autoscaling_group.autoscale_group_1.name
//
//}
//output "autoscalingname1" {
//  value = [data.aws_autoscaling_group.autoscale_group_1.name, aws_alb_target_group.alb_target_group_1.arn]
//
//}


