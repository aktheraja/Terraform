//This resource reads in from the data resource at the start of deployment (if there is a change to the launch config
//or if alwasy_switch is set to true) and updates or create a text file to track the status of ASG1

resource "null_resource" "pre-update_ASG1_status" {
  triggers = {
    the_trigger= local.force_switch?timestamp():aws_launch_configuration.autoscale_launch_config1.id
  }
 // depends_on = [aws_launch_configuration.autoscale_launch_config1]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = local.ASG1_is_active?"echo true>.ASG1Active.txt":"echo false>.ASG1Active.txt"
    //(local.new_LC||var.always_switch)&&var.first_time_create==false?"checktoProceed.sh ASG1":"echo blank step"
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
    the_trigger= local.force_switch?timestamp():aws_launch_configuration.autoscale_launch_config1.id
  }
  depends_on = [aws_launch_configuration.autoscale_launch_config1, null_resource.pre-update_ASG1_status]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = (local.new_LC||var.always_switch)&&!local.reset_needed?"checktoProceed.sh ASG1":"echo blank step"
  }
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
    command = (local.new_LC||var.always_switch)&&!local.reset_needed?"checktoProceed.sh ASG2":"echo blank step"
  }
}
//-------------------------------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------------------------------

//resource "local_file" "UD_record" {
//  depends_on = [aws_autoscaling_group.autoscale_group_2, aws_autoscaling_group.autoscale_group_1]
//  lifecycle {create_before_destroy = false}
//  content     = data.aws_launch_configuration.LC_user_data
//  filename = ".UserData_from_datasource.txt"
//}

//resource "local_file" "AMI_record" {
//  depends_on = [aws_autoscaling_group.autoscale_group_2, aws_autoscaling_group.autoscale_group_1]
//  lifecycle {create_before_destroy = false}
//  content     = data.aws_launch_configuration.LC_AMI
//  filename = ".AMI_from_data_source.txt"
//}


resource "null_resource" "set_ASG1_post_status" {
  triggers = {
    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_1.wait_for_elb_capacity, "0"])
  }

  depends_on = [aws_autoscaling_group.autoscale_group_1]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = aws_autoscaling_group.autoscale_group_1.max_size==0?"echo false>.ASG1Active.txt":"echo true>.ASG1Active.txt"
  }

}
resource "null_resource" "set_ASG2_post_status" {
  triggers = {
    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_2.max_size, "0"])
  }
  depends_on = [aws_autoscaling_group.autoscale_group_2]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = aws_autoscaling_group.autoscale_group_2.max_size==5?"echo false>.ASG1Active.txt":"echo true>.ASG1Active.txt"
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

//resource "null_resource" "update_ami" {
//  triggers = {
//    the_trigger= join(",",[null_resource.change_detected_ASG1.id, null_resource.change_detected_ASG2.id , "0"])
//  }
//  depends_on = [aws_autoscaling_group.autoscale_group_2, aws_autoscaling_group.autoscale_group_1]
//  lifecycle {create_before_destroy = true}
//
//}
