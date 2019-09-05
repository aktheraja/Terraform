
variable "availability_zones" {
  description = "A comma-delimited list of availability zones for the VPC."
  default = "us-west-2a,us-west-2b"
}

variable "ami" {
  default = "ami-07669fc90e6e6cc47"
}

variable "deployment_name"{
  default="PASON-Terraform-0downtime-BlueGreen"
}

variable "user_data_file_string"{
  default = "C:/Users/Default.Default-PC/Downloads/install_apache_server.sh"
}

variable "min_asg" {
  default = 2
}

variable "max_asg" {
  default = 4
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
  default = "t2.nano"
}

variable "always_switch" {
  default = false
}


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
  //ASG names
  ASG1Name = "asg1-${var.deployment_name}"
  ASG2Name = "asg2-${var.deployment_name}"

  //retrieve information about each ASG
  ASG1_present = contains(data.aws_autoscaling_groups.test.names, local.ASG1Name)
  ASG2_present = contains(data.aws_autoscaling_groups.test.names, local.ASG2Name)
  ASG1_capacity = local.ASG1_present?data.aws_autoscaling_group.data-ASG1[0].desired_capacity:-1
  ASG2_capacity = local.ASG2_present?data.aws_autoscaling_group.data-ASG2[0].desired_capacity:-1
  ASGs_present = local.ASG1_present&&local.ASG2_present
  ASG1_is_active = local.ASG1_capacity!=0&&local.ASG1_capacity!=-1
  ASG2_is_active = local.ASG2_capacity!=0&&local.ASG2_capacity!=-1

  //========================================================================================
  //test for different abnormal cases
  //========================================================================================
  //Checks if ASGs are both missing, both zero or one zero and one missing. This condition is used to ignore provisioners
  both_null_or_zero = (!local.ASG1_present||local.ASG1_capacity==0) && (!local.ASG2_present||local.ASG2_capacity==0)

  //Checks if there is a change in max and min bounds. Forces a switch if this is detected
  change_capacity_lim_ASG1 = local.ASG1_present?((data.aws_autoscaling_group.data-ASG1[0].max_size!=var.max_asg||data.aws_autoscaling_group.data-ASG1[0].min_size!=var.min_asg)&&local.ASG1_is_active):false
  change_capacity_lim_ASG2 = local.ASG2_present?((data.aws_autoscaling_group.data-ASG2[0].max_size!=var.max_asg||data.aws_autoscaling_group.data-ASG2[0].min_size!=var.min_asg)&&local.ASG2_is_active):false
  change_capacity_lim = local.change_capacity_lim_ASG1||local.change_capacity_lim_ASG2

  //Checks if both ASGs are non-zero. Used to ignore any pending switches so that Terraform can correct the infrastructure first
  both_non-zero = local.ASG1_capacity>0&&local.ASG2_capacity>0

  //Checks if the ASG that is meant to be zero is missing. Used to ignore any pending switches so that Terraform can correct the infrastructure first
  only_one_inactive_missing_ASG = ((!local.ASG2_present&&local.ASG1_is_active)||(!local.ASG1_present&&local.ASG2_is_active))
  //========================================================================================

  //If the inactive ASG is missing or both are non-zero, cancel the switch and allow Terraform to correct the infrastructure first.
  //The infrastructure must be reset a state with one active and one inactive before switching otherwise the switch could result in downtime
  switch_cancelled = local.only_one_inactive_missing_ASG||local.both_non-zero

  //If always_switch is set to true or there is a change in capacity,
  //a switch should be forced regardless of whether a new Launch Config is detected
  //UNLESS the switch is cancelled based on both non-zero or one zero ASG missing
  force_switch = (var.always_switch)&&!local.switch_cancelled

  //checks if there is a new Launch config based on whichever is active.
  //New Launch config is set to false when the switch is cancelled based on both non-zero or one zero ASG missing
  new_LC_ASG1 = local.ASG1_present?data.aws_autoscaling_group.data-ASG1[0].launch_configuration!=aws_launch_configuration.autoscale_launch_config1.id:false
  new_LC_ASG2 = local.ASG2_present?data.aws_autoscaling_group.data-ASG2[0].launch_configuration!=aws_launch_configuration.autoscale_launch_config1.id:false
  new_LC = (local.new_LC_ASG1||local.new_LC_ASG2)&&!local.switch_cancelled

  //========================================================================================
  //Conditions to ignore provisioners
  //========================================================================================
  //if non-active ASG and active ASG are not changing, ignore provisioners
  //also if BOTH ASGs are null or zero, also ignore provisioners
  //since the text file will not be set to true at beginning to allow one ASG to proceed
  //finally, if any ASGs are missing, ignore provisioners
  ignore_prov = ((local.ASG1_max>0&&local.ASG1_is_active) && (local.ASG2_max==0&&!local.ASG2_is_active))||((local.ASG1_max==0&&!local.ASG1_is_active) && (local.ASG2_max>0&&local.ASG2_is_active))||local.both_null_or_zero||local.switch_cancelled
  //========================================================================================
  //IMPORTANT LINE: Determines values for each ASG based on a forced_witch, which one is active, and whether there is a new launch config
  change_to_ASG_2=(local.force_switch==false&&local.ASG1_is_active==local.new_LC)||(local.force_switch&&local.ASG1_is_active)

  //set values of ASGs for that switch
  ASG1_min = local.change_to_ASG_2?0:var.min_asg
  ASG1_max = local.change_to_ASG_2?0:var.max_asg
  ASG2_min = local.change_to_ASG_2?var.min_asg:0
  ASG2_max = local.change_to_ASG_2?var.max_asg:0

}


output "change_capacity_limits" {
  value = local.change_capacity_lim
}

output "old_LC" {
  value = local.ASG1_present?data.aws_autoscaling_group.data-ASG1[0].launch_configuration:data.aws_autoscaling_group.data-ASG2[0].launch_configuration
}
output "current_LC" {
  value = aws_launch_configuration.autoscale_launch_config1.id
}
output "ASG1Max_current" {
  value = local.ASG1_max
}
output "ASG1Min_current" {
  value = local.ASG1_min
}
output "ASG2Max_current" {
  value = local.ASG2_max
}
output "ASG2Min_current" {
  value = local.ASG2_min
}
output "always_switch" {
  value = var.always_switch
}
output "switch_due_to_data" {
  value = local.new_LC
}
output "change_to_ASG2" {
  value = local.change_to_ASG_2
}

output "both_non-zero_ASGs_was_detected" {
  value = local.both_non-zero
}

output "both_null_or_zero" {
  value = local.both_null_or_zero
}
output "ASG1_was_present" {
  value = local.ASG1_present
}
output "ASG2_was_present" {
  value = local.ASG2_present
}
output "ASG1_capacity_was" {
  value = local.ASG1_capacity
}

output "ASG2_capacity_was" {
  value = local.ASG2_capacity
}

output "filtered_ASGs" {
  value = data.aws_autoscaling_groups.test.names
}

output "ignore_prov_total" {
  value = local.ignore_prov
}

output "reset_needed_switch_cancelled" {
  value = local.switch_cancelled
}
output "WARNING" {
  value = local.switch_cancelled&&(local.new_LC||var.always_switch)?": DEPLOYMENT/SWITCH CANCELLED DUE TO MISSING ASG ON CLOUD. PLEASE RUN 'terraform apply -vars always_switch-true' TO COMPLETE DEPLOYMENT":null
}
