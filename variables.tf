
variable "availability_zones" {
  description = "A comma-delimited list of availability zones for the VPC."
  default = "us-west-2a,us-west-2b"
}

variable "ami" {
  default = "ami-07669fc90e6e6cc47"
}

variable "deployment_name"{
  default="Terraform-0downtime-BlueGreen"
}

variable "user_data_file_string"{
  default = "C:/Users/Default.Default-PC/Downloads/install_apache_server.sh"
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

//variable "user_data_change1"{
//  default = true
//}

variable "always_switch" {
  default=false
}



locals {
 ASG1_is_active = tobool(chomp(file(".ASG1Active.txt")))
 old_user_data =  chomp(file(".UserData.txt"))
 old_ami =  chomp(file(".AMI.txt"))
  //switching = var.switch?1:null
 //new_LC_status = chomp(file("switchstatus.txt"))
  new_LC=local.old_user_data!=var.user_data_file_string||local.old_ami!=var.ami?true:false
 change_to_ASG_2=(var.always_switch==false&&local.ASG1_is_active==local.new_LC)||(var.always_switch&&local.ASG1_is_active)?true:false
 ASG1_max = local.change_to_ASG_2?0:var.max_asg
 ASG1_min = local.change_to_ASG_2?0:var.min_asg
 ASG2_max = local.change_to_ASG_2?var.max_asg:0
 ASG2_min = local.change_to_ASG_2?var.min_asg:0
//  ASG1_depends_on=local.change_to_ASG_2?[aws_autoscaling_group.autoscale_group_2, aws_autoscaling_attachment.alb_autoscale_2, null_resource.change_detected]:[null_resource.change_detected]
//  ASG2_depends_on=local.change_to_ASG_2?[null_resource.change_detected]:[aws_autoscaling_attachment.alb_autoscale_1, aws_autoscaling_group.autoscale_group_1, null_resource.change_detected]

}
//
//output "LC_user_data" {
//  value = aws_launch_configuration.autoscale_launch_config1.user_data
//}
//
output "raw_user_data" {
  value = local.old_user_data
}
output "switchstatus" {
  value = [local.new_LC]
}
//
output "OIA_status" {
  value = local.ASG1_is_active
}
output "changeToASG2" {
  value = local.change_to_ASG_2
}
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
//output "NS_status" {
//  value = local.new_LC_status
//}
//output "DS_status" {
//  value = var.autoswitch
//}
