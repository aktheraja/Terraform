//Launch config must have create_before_destroy=true
resource "aws_launch_configuration" "autoscale_launch_config1" {
  name_prefix          = "autoscale_launcher-${var.deployment_name}"
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.private_subnetsecurity.id]
  enable_monitoring = false
  user_data = file(var.user_data_file_string)
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [data.aws_autoscaling_groups.test]

}


resource "aws_autoscaling_group" "autoscale_group_1" {
  name = local.ASG1Name
  launch_configuration = aws_launch_configuration.autoscale_launch_config1.id
  vpc_zone_identifier  = aws_subnet.private_subnet.*.id
  depends_on = [null_resource.change_detected_ASG1] //always waits for change_detected_ASG1 to perform checktoProceed check
  min_size = local.ASG1_min
  max_size = local.ASG1_max
  //desired_capcity is set to max value when there is a new launch config, bad setup (switch cancelled), change in max and min, or always_switch is false
  desired_capacity = local.new_LC||local.force_switch||local.change_capacity_lim||local.both_null_or_zero?local.ASG1_max:null
  wait_for_elb_capacity = local.ASG1_max
  tag {
    key = "Name"
    value = "ASG1-${var.deployment_name}"
    propagate_at_launch = true
  }
  //health_check_grace_period = 400
  health_check_type = "ELB"
  default_cooldown = 60
  //must have create_before_destroy=true
  lifecycle {
    create_before_destroy = true
  }
  enabled_metrics = var.ASG_enabled_metrics
}

resource "aws_autoscaling_attachment" "alb_autoscale_1" {
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.id
  //must have create_before_destroy=true
  lifecycle {create_before_destroy = true}
}

resource "aws_autoscaling_group" "autoscale_group_2" {
  name=local.ASG2Name
  launch_configuration = aws_launch_configuration.autoscale_launch_config1.id
  //  vpc_zone_identifier  = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet1.id]
  vpc_zone_identifier  =aws_subnet.private_subnet.*.id
  min_size = local.ASG2_min
  max_size = local.ASG2_max
  //desired_capcity is set to max value when there is a new launch config, bad setup (switch cancelled), change in max and min, or always_switch is false
  desired_capacity = local.new_LC||local.force_switch||local.change_capacity_lim||local.both_null_or_zero?local.ASG2_max:null
  wait_for_elb_capacity = local.ASG2_max
  //always waits for change_detected_ASG1 to perform checktoProceed check
  depends_on = [null_resource.change_detected_ASG2]
  tag {
    key = "Name"
    value = "ASG2-${var.deployment_name}"
    propagate_at_launch = true
  }
  //health_check_grace_period = 400
  health_check_type = "ELB"
  default_cooldown = 60
  lifecycle {create_before_destroy = true}
  enabled_metrics = var.ASG_enabled_metrics
}

resource "aws_autoscaling_attachment" "alb_autoscale_2" {
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_2.id
  //must have create_before_destroy=true
  lifecycle {create_before_destroy = true}
}


resource "aws_autoscaling_policy" "policy1" {
depends_on = [aws_autoscaling_group.autoscale_group_1]
  //the name dependency on null_resource.set_ASG2_post_status.id ensure it gets recreated everytime that null resource is triggered
  name = "asgpolicy1-${null_resource.set_ASG1_post_status.id}"
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.name
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 20.0
  }
  lifecycle {
    //must have create_before_destroy=false to ensure policy is destroyed first while depoyment is ongoing
    create_before_destroy = false
    ignore_changes = [adjustment_type]
  }
}
resource "aws_autoscaling_policy" "policy2" {
  depends_on = [aws_autoscaling_group.autoscale_group_2]
  //the name dependency on null_resource.set_ASG2_post_status.id ensure it gets recreated everytime that null resource is triggered
  name = "asgpolicy2-${null_resource.set_ASG2_post_status.id}"
  adjustment_type = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_2.name
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 20.0
  }
  lifecycle {
    //must have create_before_destroy=false to ensure policy is destroyed first while depoyment is ongoing
    create_before_destroy = false
    ignore_changes = [adjustment_type]
  }
}

