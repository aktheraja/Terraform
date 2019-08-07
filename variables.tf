
variable "availability_zones" {
  description = "A comma-delimited list of availability zones for the VPC."
  default = "us-west-2a,us-west-2b"
}
variable "ami_key_pair_name" {
  default = "MyKP"
}
variable "ami" {
  default = "ami-07669fc90e6e6cc47"
}

variable "deployment_name"{
  default="Craig-"
}

variable "user_data_file_string"{
  default = "C:/Users/Default.Default-PC/Downloads/install_apache_server.sh"
}

variable "autoswitch" {
  default=true
}

variable "min_asg" {
  default = 2
}

variable "max_asg" {
  default = 5
}

variable "ASG_health_check_grace"{
  default=30
}

variable "ASG_health_check_type"{
  default="ELB"
}

variable "ASG_enabled_metrics" {
  default=["GroupInServiceInstances","GroupTotalInstances"]
}

variable "instance_type" {
  default = "t2.nano"
}
//
//variable "stored_ASG1_max_size"{
//  default=chomp(file("ASG1MaxSize.txt"))
//}

locals {
  ASG1_is_active = chomp(file("ASG1MaxSize.txt"))==0?true:false
  new_switch = (aws_launch_configuration.autoscale_launch_config.user_data==file(var.user_data_file_string)) && (aws_launch_configuration.autoscale_launch_config.image_id==var.ami)?true:false
  ASG1_max = (var.autoswitch==true && local.ASG1_is_active==local.new_switch)||(var.autoswitch==false && local.ASG1_is_active==1)?var.max_asg:0
  ASG1_min = (var.autoswitch==true && local.ASG1_is_active==local.new_switch)||(var.autoswitch==false && local.ASG1_is_active==1)?var.min_asg:0
  ASG2_max = (var.autoswitch==true && local.ASG1_is_active==local.new_switch)||(var.autoswitch==false && local.ASG1_is_active==1)?0:var.max_asg
  ASG2_min = (var.autoswitch==true && local.ASG1_is_active==local.new_switch)||(var.autoswitch==false && local.ASG1_is_active==1)?0:var.min_asg

}

output "OIA_status" {
  value = local.ASG1_is_active
}
output "ASG1Max" {
  value = local.ASG1_max
}
output "ASG1Min" {
  value = local.ASG1_min
}
output "ASG2Max" {
  value = local.ASG2_max
}
output "ASG2Min" {
  value = local.ASG2_min
}
output "NS_status" {
  value = local.new_switch
}
output "DS_status" {
  value = var.autoswitch
}
