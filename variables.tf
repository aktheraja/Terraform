
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
  default="Terraform-0downtime-BlueGreen"
}

variable "user_data_file_string"{
  default = "C:/Users/Default.Default-PC/Downloads/install_apache_server2.sh"
}



variable "min_asg" {
  default = 2
}

variable "max_asg" {
  default = 5
}

variable "ASG_health_check_grace"{
  default=200
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

//variable "stored_ASG1_max_size"{
//  default=chomp(file("ASG1MaxSize.txt"))
//}
//
variable "asg1_tag" {
  default="active"
}
variable "asg2_tag" {
  default="inactive"
}

variable "ASG1_is_active"{
  default = false
}

variable "autoswitch" {
  default=true
}

variable "list"{
  default=[1,2,3,4,5]
}

locals {
 // ASG1_is_active = aws_autoscaling_group.autoscale_group_1.tag["Status"].value=="active"?true:false
  new_switch = chomp(file("switchstatus.txt"))
  ASG1_max = (var.autoswitch==true && var.ASG1_is_active==local.new_switch)||(var.autoswitch==false && var.ASG1_is_active==1)?var.max_asg:0
  ASG1_min = (var.autoswitch==true && var.ASG1_is_active==local.new_switch)||(var.autoswitch==false && var.ASG1_is_active==1)?var.min_asg:0
  ASG2_max = (var.autoswitch==true && var.ASG1_is_active==local.new_switch)||(var.autoswitch==false && var.ASG1_is_active==1)?0:var.max_asg
  ASG2_min = (var.autoswitch==true && var.ASG1_is_active==local.new_switch)||(var.autoswitch==false && var.ASG1_is_active==1)?0:var.min_asg
//
}
//
//output "LC_user_data" {
//  value = aws_launch_configuration.autoscale_launch_config1.user_data
//}
//
//output "raw_user_data" {
//  value = var.user_data_file_string
//}
//
////output "OIA_status" {
////  value = local.ASG1_is_active
////}
//output "ASG1Max" {
//  value = local.ASG1_max
//}
//output "ASG1Min" {
//  value = local.ASG1_min
//}
//output "ASG2Max" {
//  value = local.ASG2_max
//}
//output "ASG2Min" {
//  value = local.ASG2_min
//}
////output "NS_status" {
////  value = local.new_switch
////}
//output "DS_status" {
//  value = var.autoswitch
//}
