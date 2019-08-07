resource "aws_autoscaling_group" "autoscale_group_1" {
  name_prefix=var.deployment_name
  launch_configuration = aws_launch_configuration.autoscale_launch_config.id
  vpc_zone_identifier  =aws_subnet.private_subnet.*.id
  min_size = local.ASG1_min
  max_size = local.ASG1_max
  desired_capacity = local.ASG1_max
  min_elb_capacity = local.ASG1_max

  tag {
    key                 = "Name"
    value               = "auto_scale1"
    propagate_at_launch = true
  }

  health_check_grace_period = var.ASG_health_check_grace
  health_check_type = var.ASG_health_check_type
  lifecycle {create_before_destroy = true}
  enabled_metrics = var.ASG_enabled_metrics
  provisioner "local-exec" {
    command = "echo ${self.max_size}>ASG1MaxSize.txt"
  }
//  provisioner "local-exec" {
//    command = "check_health.sh ${aws_alb.alb.dns_name} asg-autoscale_launcher-nikky-20190731200646732400000001 aws_alb_target_group.alb_target_group_1.arn"
//  }
}

resource "aws_autoscaling_group" "autoscale_group_2" {
  name_prefix=var.deployment_name
  launch_configuration = aws_launch_configuration.autoscale_launch_config.id
  vpc_zone_identifier  =aws_subnet.private_subnet.*.id
  min_size = local.ASG2_min
  max_size = local.ASG2_max
  desired_capacity = local.ASG2_max
  min_elb_capacity = local.ASG2_max

  tag {
    key                 = "Name"
    value               = "auto_scale2"
    propagate_at_launch = true
  }
  health_check_grace_period = var.ASG_health_check_grace
  health_check_type = var.ASG_health_check_type
  lifecycle {create_before_destroy = true}
  enabled_metrics = var.ASG_enabled_metrics
  //  provisioner "local-exec" {
  //    command = "check_health.sh ${aws_alb.alb.dns_name} asg-autoscale_launcher-nikky-20190731200646732400000001 aws_alb_target_group.alb_target_group_1.arn"
  //  }
}

resource "aws_autoscaling_attachment" "alb_autoscale" {
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name =local.ASG1_is_active==true?aws_autoscaling_group.autoscale_group_1.id:aws_autoscaling_group.autoscale_group_2.id
  lifecycle {create_before_destroy = true}
//  provisioner "local-exec" {
//    command = "attchmnt_checkhealth.sh asg-autoscale_launcher-nikky-20190725064518336300000001 ${aws_alb_target_group.alb_target_group_1.arn}"
//  }
}

resource "aws_launch_configuration" "autoscale_launch_config" {
  name_prefix          = var.deployment_name
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.private_subnesecurity.id]
  enable_monitoring = true
  user_data = file(var.user_data_file_string)
  lifecycle {create_before_destroy = true}
}
