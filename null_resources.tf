//resource "null_resource" "set_ASG_not_done" {
//  triggers = {
//    the_trigger= var.always_switch?timestamp():aws_launch_configuration.autoscale_launch_config1.id
//  }
//  depends_on = []
//  lifecycle {
//    create_before_destroy = true
//  }
//  provisioner "local-exec" {
//    command =  "echo false>Done_stat.txt"
//  }
//}


resource "null_resource" "change_detected_ASG1" {

  triggers = {
    the_trigger= var.always_switch?timestamp():aws_launch_configuration.autoscale_launch_config1.id
  }
  depends_on = [aws_launch_configuration.autoscale_launch_config1]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command = local.new_LC||var.always_switch?"checktoProceed.sh ASG1":"echo blank step"
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
    command = local.new_LC||var.always_switch?"checktoProceed.sh ASG2":"echo blank step"
  }

}

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

//resource "null_resource" "set_ASG_done" {
//  triggers = {
//    the_trigger = join(",", [
//      null_resource.set_ASG2_post_status,
//      null_resource.set_ASG1_post_status,
//      "0"])
//  }
//  depends_on = [
//    null_resource.set_ASG2_post_status,
//    null_resource.set_ASG1_post_status]
//  lifecycle {
//    create_before_destroy = true
//  }
//  provisioner "local-exec" {
//    command = "echo true>Done_stat.txt"
//  }
//
//}
//
resource "null_resource" "write_curr_UserData" {
  triggers = {
    the_trigger= join(",",[aws_launch_configuration.autoscale_launch_config1.id, "0"])
  }
  depends_on = [aws_autoscaling_group.autoscale_group_1, aws_autoscaling_group.autoscale_group_2]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command ="echo ${var.user_data_file_string}>.UserData.txt"
  }

}
resource "null_resource" "write_curr_AMI" {
  triggers = {
    the_trigger= join(",",[aws_launch_configuration.autoscale_launch_config1.id, "0"])
  }
  depends_on = [aws_autoscaling_group.autoscale_group_1, aws_autoscaling_group.autoscale_group_2]
  lifecycle {create_before_destroy = true}
  provisioner "local-exec" {
    command ="echo ${var.ami}>.AMI.txt"
  }

}

//resource "null_resource" "set_ASG1_status" {
//  triggers = {
//    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_1.max_size, "0"])
//  }
//  depends_on = [aws_autoscaling_group.autoscale_group_1, aws_autoscaling_group.autoscale_group_2]
//  lifecycle {create_before_destroy = true}
//  provisioner "local-exec" {
//    command = aws_autoscaling_group.autoscale_group_1.max_size==0?"echo false>ASG1Active.txt":"echo true>ASG1Active.txt"
//  }

//
//resource "null_resource" "set_ASG2_depends_on" {
//  triggers = {
//    the_trigger= join(",",[aws_launch_configuration.autoscale_launch_config1.id, "0"])
//  }
//  depends_on = [aws_autoscaling_group.autoscale_group_1, aws_autoscaling_group.autoscale_group_2]
//  lifecycle {create_before_destroy = true}
//  provisioner "local-exec" {
//    command = aws_autoscaling_group.autoscale_group_1.max_size==0?"echo [aws_autoscaling_group.autoscale_group_1, null_resource.change_detected]>ASG2Depends.txt":"echo [null_resource.change_detected]>ASG2Depends.txt"
//  }
//
//}
//resource "null_resource" "ASG1_trigger" {
//  triggers = {
//    the_trigger= true?join(",",[aws_autoscaling_group.autoscale_group_1.max_size, "0"]):join(",",[aws_autoscaling_group.autoscale_group_2.max_size, "0"])
//  }
//  //depends_on = [aws_autoscaling_group.autoscale_group_1, aws_autoscaling_group.autoscale_group_2]
//  lifecycle {create_before_destroy = true}
//}
//
//resource "null_resource" "ASG2_trigger" {
//  triggers = {
//    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_2.max_size, "0"])
//  }
//  //depends_on = [aws_autoscaling_group.autoscale_group_1, aws_autoscaling_group.autoscale_group_2]
//  lifecycle {create_before_destroy = true}
//
//
//}

//resource "null_resource" "packer" {
//  triggers = {
//    build_number = "${timestamp()}"
//  }
//  provisioner "local-exec" {
//    command = "sleep 3"
//  }
//}