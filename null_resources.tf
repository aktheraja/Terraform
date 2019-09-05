//This resource reads in from the data resource at the start of deployment (if there is a change to the launch config
//or if alwasy_switch is set to true) and updates or create a text file to track the status of ASG1

resource "null_resource" "pre-update_ASG1_status" {
  triggers = {
    the_trigger= local.force_switch?timestamp():aws_launch_configuration.autoscale_launch_config1.id
  }
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = local.ASG1_is_active?"echo true>.ASG1Active.txt":"echo false>.ASG1Active.txt"

  }

}
//change_detected_ASG1 and change_detected_ASG2 are triggered whenever a new launch config occurs or when always switch is true
//they perform the provisioner check on which ASG should proceed first. The check is based on the status in the .ASG1Active.txt file
//They allow the inactive ASG to proceed and hold up the other till the state of .ASG1Active changes
//bash file check is performed only when a new Launch Config is present or always_switch is true AND it is not not a first_time deployment
//-------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
resource "null_resource" "change_detected_ASG1" {
  triggers = {
    the_trigger = local.force_switch?timestamp():aws_launch_configuration.autoscale_launch_config1.id
  }
  depends_on = [aws_launch_configuration.autoscale_launch_config1, null_resource.pre-update_ASG1_status]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = local.ignore_prov?"echo blank step":"checktoProceed.sh ASG1"
    //"#!/bin/bash; while true; do line=$(head -n 1 .ASG1Active.txt); if [ $line == false ]; then exit 0 ; else echo Waiting for ASG2; fi; sleep 10; done"
  }
  //"checktoProceed.sh ASG1"
}

resource "null_resource" "change_detected_ASG2" {
  triggers = {
    the_trigger= local.force_switch?timestamp():aws_launch_configuration.autoscale_launch_config1.id
  }
  depends_on = [aws_launch_configuration.autoscale_launch_config1, null_resource.pre-update_ASG1_status]
  lifecycle {
    create_before_destroy = true
  }
  provisioner "local-exec" {
    command = local.ignore_prov?"echo blank step":"checktoProceed.sh ASG2"
  }
}
//-------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------
//
//resource "null_resource" "ASG1_depends_on" {
//  count=0
//  //count = local.ASG1_min==0&&local.ASGs_present?1:0
//  triggers = {
//    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_2.desired_capacity, "0"])
//  }
//  depends_on = [aws_autoscaling_group.autoscale_group_2]
//  lifecycle {create_before_destroy = true}
//}
//
//resource "null_resource" "ASG2_depends_on" {
//  count = 0
////  count = local.ASG2_min==0&&local.ASGs_present?1:0
//  triggers = {
//    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_1.desired_capacity, "0"])
//  }
//  depends_on = [aws_autoscaling_group.autoscale_group_1]
//  lifecycle {create_before_destroy = true}
//}



resource "null_resource" "set_ASG1_post_status" {
  triggers = {
    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_1.desired_capacity, "0"])
  }

  depends_on = [aws_autoscaling_group.autoscale_group_1]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = aws_autoscaling_group.autoscale_group_1.max_size==var.max_asg?"echo true>.ASG1Active.txt":"echo false>.ASG1Active.txt"
  }

}
resource "null_resource" "set_ASG2_post_status" {
  triggers = {
    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_2.desired_capacity, "0"])
  }
  depends_on = [aws_autoscaling_group.autoscale_group_2]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = aws_autoscaling_group.autoscale_group_2.max_size==var.max_asg?"echo false>.ASG1Active.txt":"echo true>.ASG1Active.txt"
  }
}
//resource "null_resource" "update_user_data_and_AMI" {
//  triggers = {
//    the_trigger= join(",",[null_resource.change_detected_ASG1.id, null_resource.change_detected_ASG2.id , "0"])
//  }
//  depends_on = [aws_autoscaling_group.autoscale_group_2, aws_autoscaling_group.autoscale_group_1]
//  lifecycle {create_before_destroy = true}
//  provisioner "local-exec" {
//    command = "echo ${var.user_data_file_string}>.UserData.txt"
//  }
//  provisioner "local-exec" {
//    command = "echo ${var.ami}>.AMI.txt"
//  }
//}

