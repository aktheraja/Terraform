
//change_detected_ASG1 and change_detected_ASG2 are triggered whenever a new launch config occurs or when always switch is true
//they perform the provisioner check on which ASG should proceed first. The check is based on the status in the .ASG1Active.txt file
//They allow the inactive ASG to proceed and hold up the other till the state of .ASG1Active changes
//bash file check is performed only when a new Launch Config is present or always_switch is true AND it is not not a first_time deployment
//-------------------------------------------------------------------------------------------------------------------------------------
resource "null_resource" "change_detected_ASG1" {
  triggers = {
    the_trigger= var.always_switch?timestamp():aws_launch_configuration.autoscale_launch_config1.id
  }
  depends_on = [aws_launch_configuration.autoscale_launch_config1]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = (local.new_LC||var.always_switch)&&var.first_time_create==false?"./checktoProceed.sh ASG1":"echo blank step"
  }
}

resource "null_resource" "change_detected_ASG2" {
  triggers = {
    the_trigger= var.always_switch?timestamp():aws_launch_configuration.autoscale_launch_config1.id
  }
  depends_on = [aws_launch_configuration.autoscale_launch_config1]
  lifecycle {
    create_before_destroy = true
  }
  provisioner "local-exec" {
    command = (local.new_LC||var.always_switch)&&var.first_time_create==false?"./checktoProceed.sh ASG2":"echo blank step"
  }
}
//-------------------------------------------------------------------------------------------------------------------------------------

resource "null_resource" "set_ASG1_post_status" {
  triggers = {
    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_1.max_size, "0"])
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
resource "null_resource" "update_user_data" {
  triggers = {
    the_trigger= join(",",[null_resource.change_detected_ASG1.id, null_resource.change_detected_ASG2.id , "0"])
  }
  depends_on = [aws_autoscaling_group.autoscale_group_2, aws_autoscaling_group.autoscale_group_1]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = "echo ${var.user_data_file_string}>.UserData.txt"
  }
}

resource "null_resource" "update_ami" {
  triggers = {
    the_trigger= join(",",[null_resource.change_detected_ASG1.id, null_resource.change_detected_ASG2.id , "0"])
  }
  depends_on = [aws_autoscaling_group.autoscale_group_2, aws_autoscaling_group.autoscale_group_1]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = "echo ${var.ami}>.AMI.txt"
  }
}
