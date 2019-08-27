
variable "availability_zones" {
  description = "A comma-delimited list of availability zones for the VPC."
  default = "us-west-2a,us-west-2b"
}

variable "ami" {
  default = "ami-07669fc90e6e6cc47"
}

variable "deployment_name"{
  default="CRAIG-Terraform-0downtime-BlueGreen"
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
  default = 200
}

variable "ASG_health_check_type"{
  default="ELB"
}

variable "ASG_enabled_metrics" {
  default=[]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "always_switch" {
  default = false
}

variable "rollback" {
  default = false
}
//data "aws_launch_configuration" "old_LC" {
//  count=local.ASG1_present?1:0
//  name = data.aws_autoscaling_group.data-ASG1[0].launch_configuration
//}

data "aws_autoscaling_group" "data-ASG1" {
  count=local.ASG1_present?1:0
  name = local.ASG1Name
}
data "aws_autoscaling_group" "data-ASG2" {
  count=local.ASG2_present?1:0
  name = local.ASG2Name
}
data "aws_autoscaling_groups" "test" {
  filter {
    name = "auto-scaling-group"
    values = [local.ASG2Name, local.ASG1Name]
  }

}

locals {
  ASG1Name = "asg1-${var.deployment_name}"
  ASG2Name = "asg2-${var.deployment_name}"

  ASG1_present = contains(data.aws_autoscaling_groups.test.names, local.ASG1Name)
  ASG2_present = contains(data.aws_autoscaling_groups.test.names, local.ASG2Name)
  ASG1_capacity = local.ASG1_present?data.aws_autoscaling_group.data-ASG1[0].desired_capacity:-1
  ASG2_capacity = local.ASG2_present?data.aws_autoscaling_group.data-ASG2[0].desired_capacity:-1
  ASGs_present = local.ASG1_present&&local.ASG2_present
  bad_setup = (local.ASG1_capacity==0&&local.ASG2_capacity==0)||(local.ASG1_capacity!=0&&local.ASG2_capacity!=0)
  reset_needed = !local.ASGs_present||local.bad_setup
  force_switch = local.reset_needed||var.always_switch
  new_LC=local.ASG1_present?data.aws_autoscaling_group.data-ASG1[0].launch_configuration!=aws_launch_configuration.autoscale_launch_config1.id:data.aws_autoscaling_group.data-ASG2[0].launch_configuration!=aws_launch_configuration.autoscale_launch_config1.id
  ASG1_is_active = local.ASG1_capacity!=0&&local.ASG1_capacity!=-1
  ASG2_is_active = local.ASG2_capacity!=0&&local.ASG2_capacity!=-1
  ignore_prov1 = ((!local.ASG1_present||local.ASG1_capacity==0) && (!local.ASG2_present||local.ASG2_capacity==0))
  ignore_prov2 = ((local.ASG1_max>0&&local.ASG1_is_active) && (local.ASG2_max==0&&!local.ASG2_is_active))||((local.ASG1_max==0&&!local.ASG1_is_active) && (local.ASG2_max>0&&local.ASG2_is_active))
  ignore_prov = local.ignore_prov1||local.ignore_prov2
  change_to_ASG_2=(var.always_switch==false&&local.ASG1_is_active==local.new_LC)||((var.always_switch)&&local.ASG1_is_active)
  ASG1_min = local.change_to_ASG_2?0:var.min_asg
  ASG1_max = local.change_to_ASG_2?0:var.max_asg
  ASG2_min = local.change_to_ASG_2?var.min_asg:0
  ASG2_max = local.change_to_ASG_2?var.max_asg:0
}

output "ASGsPresent" {
  value = local.ASGs_present
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
output "always_switch_on" {
  value = var.always_switch
}
output "switched_due_to_data" {
  value = local.new_LC
}
output "change_was_required_to_ASG2" {
  value = local.change_to_ASG_2
}
output "asg1dataLC" {
  value = data.aws_autoscaling_group.data-ASG1[0].launch_configuration
}
output "asg_newLC" {
  value = aws_launch_configuration.autoscale_launch_config1.id
}
output "reset_was_needed" {
  value = local.reset_needed
}
output "ASG1_present_before_apply" {
  value = local.ASG1_present
}
output "ASG2_present_before_apply" {
  value = local.ASG2_present
}
output "ASG1_capacity_before_apply" {
  value = local.ASG1_capacity
}

output "ASG2_capacity_before_apply" {
  value = local.ASG2_capacity
}

output "ignoring_checkToProceed" {
  value = local.ignore_prov
}