
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

//  ASG1_max_capacity = lookup(data.aws_autoscaling_group.data-ASG1[0],"min_size")==0||lookup(data.aws_autoscaling_group.data-ASG1[0],"min_size")==var.min_asg?data.aws_autoscaling_group.data-ASG1[0].max_size:-1
//  ASG2_max_capacity = lookup(data.aws_autoscaling_group.data-ASG2[0],"min_size")==0||lookup(data.aws_autoscaling_group.data-ASG2[0],"min_size")==var.min_asg?data.aws_autoscaling_group.data-ASG2[0].max_size:-1
  //ASG2_current_capacity = lookup(data.aws_autoscaling_group.data-ASG2[0],"desired_capacity",false)?false:true
  ASGs_present = local.ASG1_present&&local.ASG2_present
  bad_setup = (local.ASG1_capacity==0&&local.ASG2_capacity==0)||(local.ASG1_capacity!=0&&local.ASG2_capacity!=0)
  reset_needed = !local.ASGs_present||local.bad_setup
  force_switch = local.reset_needed||var.always_switch
  //reset_needed = (local.ASG1_max_capacity==0&&local.ASG1_max_capacity==0)||local.ASG1_max_capacity==-1||local.ASG2_max_capacity==-1?true:false
  //check_LC = data.aws_autoscaling_group.data-ASG1[0].launch_configuration==aws_launch_configuration.autoscale_launch_config1.id
  new_LC=local.ASGs_present?data.aws_autoscaling_group.data-ASG1[0].launch_configuration!=aws_launch_configuration.autoscale_launch_config1.id:false
//||local.ASG_data_present1=="nothing"||local.ASG_data_present2=="nothing"
  ASG1_is_active = local.ASG1_capacity!=0&&local.ASG1_capacity!=-1
  ASG2_is_active = local.ASG2_capacity!=0&&local.ASG2_capacity!=-1
  ignore_prov1 = ((!local.ASG1_present||local.ASG1_capacity==0) && (!local.ASG2_present||local.ASG2_capacity==0))
  ignore_prov2 = ((local.ASG1_max>0&&local.ASG1_is_active) && (local.ASG2_max==0&&!local.ASG2_is_active))||((local.ASG1_max==0&&!local.ASG1_is_active) && (local.ASG2_max>0&&local.ASG2_is_active))
  ignore_prov = local.ignore_prov1||local.ignore_prov2
  //new_LC = false//data.aws_autoscaling_group.data-ASG1[0].launch_configuration==aws_launch_configuration.autoscale_launch_config1.id?false:true
  //current_capacity=var.set_to_max==true?var.max_asg:data.aws_autoscaling_group.test_spec.desired_capacity
  //change_when_dead = (!local.ASG2_present&&local.ASG1_is_active)
  change_to_ASG_2=(var.always_switch==false&&local.ASG1_is_active==local.new_LC)||((var.always_switch)&&local.ASG1_is_active)
  ASG1_min = local.change_to_ASG_2?0:var.min_asg
  ASG1_max = local.change_to_ASG_2?0:var.max_asg
  ASG2_min = local.change_to_ASG_2?var.min_asg:0
  ASG2_max = local.change_to_ASG_2?var.max_asg:0
}

output "ASGsPresent" {
  value = local.ASGs_present
}

//output "LC_check" {
//  value = local.check_LC
//  //
//}
output "old_LC" {
  value = data.aws_autoscaling_group.data-ASG1[0].launch_configuration
}
output "current_LC" {
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
//output "first_time_create" {
//  value = var.first_time_create
//}
output "reset_needed" {
  value = local.reset_needed
}
output "ASG1_present" {
  value = local.ASG1_present
}
output "ASG2_present" {
  value = local.ASG2_present
}
output "ASG1_capacity" {
  value = local.ASG1_capacity
}

output "ASG2_capacity" {
  value = local.ASG2_capacity
}

output "ASGsData" {
  value = data.aws_autoscaling_groups.test
}

output "filtered_ASGs" {
  value = data.aws_autoscaling_groups.test.names
}

output "new_LC" {
  value = local.new_LC
}

output "ignore_prov" {
  value = local.ignore_prov
}