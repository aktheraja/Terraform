
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
  default = "C:/Users/Default.Default-PC/Downloads/install_apache_server2.sh"
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

variable "first_time_create" {
  description = "By setting to true, disables checktoProceed.sh. Will thus not be a zero downtime while true. Only make true for initial creation."
  default = false
}

//data "aws_launch_configuration" "LC_user_data" {
//  name = aws_launch_configuration.autoscale_launch_config1.user_data
//}
data "aws_autoscaling_group" "test_spec" {
  //count=var.first_time_create?0:1
  name = local.ASG1Name
}
data "aws_launch_configuration" "test" {
  //count=var.first_time_create?0:1
  name = data.aws_autoscaling_group.test_spec.launch_configuration
}

//output "awsASG2" {
//  value = data.aws_autoscaling_group.test_spec
//}
//output "awsASG" {
//  value = data.aws_autoscaling_group.test
//}

locals {
 ASG1Name = "asg1-${var.deployment_name}"
 ASG1_is_active = data.aws_autoscaling_group.test_spec.max_size==5?true:false//tobool(chomp(file(".ASG1Active.txt")))
 new_LC = data.aws_autoscaling_group.test_spec.launch_configuration==aws_launch_configuration.autoscale_launch_config1.id?false:true
current_capacity=data.aws_autoscaling_group.test_spec.desired_capacity
  // old_user_data =  chomp(file(".UserData.txt"))
// old_ami =  chomp(file(".AMI.txt"))
 //new_LC=local.old_user_data!=var.user_data_file_string||local.old_ami!=var.ami?true:false
 change_to_ASG_2=(var.always_switch==false&&local.ASG1_is_active==local.new_LC)||(var.always_switch&&local.ASG1_is_active)?true:false
  ASG1_min = local.change_to_ASG_2?0:var.min_asg
  ASG1_max = local.change_to_ASG_2?0:var.max_asg
  ASG2_min = local.change_to_ASG_2?var.min_asg:0
  ASG2_max = local.change_to_ASG_2?var.max_asg:0
}

output "new_LC_present" {
  value = local.new_LC
}
output "current_LC_full" {
  value = data.aws_launch_configuration.test.id
}

output "new_raw_user_data" {
  value = aws_launch_configuration.autoscale_launch_config1.id
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
output "always_switch" {
  value = var.always_switch
}
output "switch_due_to_data" {
  value = local.new_LC
}
output "change_to_ASG2" {
  value = local.change_to_ASG_2
}
output "first_time_create" {
  value = var.first_time_create
}
