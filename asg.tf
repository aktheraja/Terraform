resource "aws_launch_configuration" "autoscale_launch_config1" {
  name_prefix          = "autoscale_launcher1-Craig-"
  image_id        = var.ami
  instance_type   = "t2.nano"
  //  key_name        = var.ami_key_pair_name
  security_groups = [aws_security_group.security.id]
  enable_monitoring = true
  user_data = file(
  "C:/Users/Default.Default-PC/Downloads/install_apache_server.sh"
  )
  lifecycle {create_before_destroy = true}
}
resource "aws_launch_configuration" "autoscale_launch_config2" {
  name_prefix          = "autoscale_launcher2-Craig-"
  image_id        = var.ami
  instance_type   = "t2.nano"
  //  key_name        = var.ami_key_pair_name
  security_groups = [aws_security_group.security.id]
  enable_monitoring = true
  user_data = file(
  "C:/Users/Default.Default-PC/Downloads/install_apache_server.sh"
  )
  lifecycle {create_before_destroy = true}
}
resource "aws_autoscaling_group" "autoscale_group_1" {
  name="asg1"
  launch_configuration = aws_launch_configuration.autoscale_launch_config1.id
  vpc_zone_identifier  = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet1.id]

//  depends_on = [aws_autoscaling_group.autoscale_group_2, aws_autoscaling_attachment.alb_autoscale_2]
//    min_size = 0
//    max_size = 0
//    desired_capacity = 0
//    wait_for_elb_capacity = 0
  min_size = var.min_asg
  max_size = var.max_asg
  desired_capacity = var.max_asg
  wait_for_elb_capacity = var.max_asg

  tag {
    key                 = "Name"
    value               = "auto_scale1-Craig"
    propagate_at_launch = true
  }

  health_check_grace_period = 200
  health_check_type = "ELB"
  //load_balancers = [aws_alb.alb.name]
  lifecycle {create_before_destroy = true}
  enabled_metrics = [

    "GroupInServiceInstances",
    "GroupTotalInstances"

  ]

  //metrics_granularity="1Minute"
//  provisioner "local-exec" {
//    command = "test.sh ${var.max_asg} ${self.name}"
//  }
}

resource "aws_autoscaling_attachment" "alb_autoscale" {
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.id
  lifecycle {create_before_destroy = true}
//  provisioner "local-exec" {
//    command = "attchmnt_checkhealth.sh ${chomp(file("C:/Users/Default.Default-PC/Dropbox/Pason/Terraform/ASGName.txt"))} ${aws_alb_target_group.alb_target_group_1.arn}"
//  }
  //${file("C:/Users/Default.Default-PC/Dropbox/Pason/Terraform/ASGName.txt")}
}
resource "aws_autoscaling_group" "autoscale_group_2" {
  name="asg2"
  launch_configuration = aws_launch_configuration.autoscale_launch_config2.id
  vpc_zone_identifier  = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet1.id]
depends_on = [aws_autoscaling_attachment.alb_autoscale, aws_autoscaling_group.autoscale_group_1]
  min_size = 0
  max_size = 0
  desired_capacity = 0
  wait_for_elb_capacity = 0

//  min_size = var.min_asg
//  max_size = var.max_asg
//  desired_capacity = var.max_asg
//  wait_for_elb_capacity = var.max_asg

  tag {
    key                 = "Name"
    value               = "auto_scale2-Craig"
    propagate_at_launch = true
  }

  health_check_grace_period = 200
  health_check_type = "ELB"
  //load_balancers = [aws_alb.alb.name]
  lifecycle {create_before_destroy = true}
  enabled_metrics = [

    "GroupInServiceInstances",
    "GroupTotalInstances"

  ]
  //depends_on = [data.aws_autoscaling_group.autoscale_group_1]
  //metrics_granularity="1Minute"
//  provisioner "local-exec" {
//    command = "test.sh ${var.max_asg} ${self.name}"
//  }
}

resource "aws_autoscaling_attachment" "alb_autoscale_2" {
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_2.id
  lifecycle {create_before_destroy = true}
//  provisioner "local-exec" {
//    command = "attchmnt_checkhealth.sh ${chomp(file("C:/Users/Default.Default-PC/Dropbox/Pason/Terraform/ASGName.txt"))} ${aws_alb_target_group.alb_target_group_1.arn}"
//  }
  //${file("C:/Users/Default.Default-PC/Dropbox/Pason/Terraform/ASGName.txt")}
}
//
//resource "null_resource" "writeASGtoFile" {
//  triggers = {
//    the_trigger= join(",",[aws_autoscaling_group.autoscale_group_1.id, "0"])
//  }
//  depends_on = [aws_autoscaling_attachment.alb_autoscale]
//  lifecycle {create_before_destroy = true}
//  provisioner "local-exec" {
//    command = "echo ${data.aws_autoscaling_group.autoscale_group_1.name}>ASGName.txt"
//  }
//
//}


/*
resource "aws_autoscaling_policy" "web_policy_up" {
  name = "web_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.autoscale_group_1.name}"
//  autoscaling_group_name = "${aws_autoscaling_group.web.name}"
  lifecycle {create_before_destroy = true}
}*/