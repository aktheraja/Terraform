resource "aws_launch_configuration" "autoscale_launch_config1" {
  name_prefix          = "autoscale_launcher-${var.deployment_name}"
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.security.id]
  enable_monitoring = true
  user_data = file(var.user_data_file_string)
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscale_group_1" {
  name = "asg1-${var.deployment_name}"
  launch_configuration = aws_launch_configuration.autoscale_launch_config1.id
  vpc_zone_identifier = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet1.id]
  depends_on = [null_resource.change_detected_ASG1]
  min_size = local.ASG1_min
  max_size = local.ASG1_max
  desired_capacity = local.new_LC||var.always_switch||var.first_time_create?local.ASG1_max:null
  wait_for_elb_capacity = local.ASG1_max
  tag {
    key = "Name"
    value = "ASG1-${var.deployment_name}"
    //value = (var.autoswitch==false && chomp(file("ASG1Active.txt"))==chomp(file("switchstatus.txt")))||(var.autoswitch==true && chomp(file("ASG1Active.txt"))==true)?"Set ASG2 to-${aws_autoscaling_group.autoscale_group_2.max_size}":"No change"
    propagate_at_launch = true
  }
  health_check_grace_period = 200
  health_check_type = "ELB"
  lifecycle {
    create_before_destroy = true
  }
  enabled_metrics = var.ASG_enabled_metrics
}

resource "aws_autoscaling_attachment" "alb_autoscale_1" {
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.id
  lifecycle {create_before_destroy = true}
}

resource "aws_autoscaling_group" "autoscale_group_2" {
  name="asg2-${var.deployment_name}"
  launch_configuration = aws_launch_configuration.autoscale_launch_config1.id
  vpc_zone_identifier  = [aws_subnet.private_subnet2.id, aws_subnet.private_subnet1.id]
  min_size = local.ASG2_min
  max_size = local.ASG2_max
  desired_capacity = local.new_LC||var.always_switch||var.first_time_create?local.ASG2_max:null
  wait_for_elb_capacity = local.ASG2_max
  depends_on = [null_resource.change_detected_ASG2]
  tag {
    key = "Name"
    value = "ASG2-${var.deployment_name}"
    propagate_at_launch = true
  }
  health_check_grace_period = 200
  health_check_type = "ELB"
  lifecycle {create_before_destroy = true}
  enabled_metrics = var.ASG_enabled_metrics
}

resource "aws_autoscaling_attachment" "alb_autoscale_2" {
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_2.id
  lifecycle {create_before_destroy = true}
}


resource "aws_autoscaling_policy" "policy1" {
  name = "asgpolicy1-${null_resource.change_detected_ASG1.id}"
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
    create_before_destroy = false
    ignore_changes = [adjustment_type]
  }
}
resource "aws_autoscaling_policy" "policy2" {
  name = "asgpolicy2-${null_resource.change_detected_ASG2.id}"
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
    create_before_destroy = false
    ignore_changes = [adjustment_type]
  }
}

//resource "aws_autoscaling_policy" "web_policy_up" {
//  name = "web_policy_up"
//  scaling_adjustment = 1
//  adjustment_type = "ChangeInCapacity"
//  cooldown = 300
//  autoscaling_group_name = "${aws_autoscaling_group.autoscale_group_1.name}"
//  lifecycle {create_before_destroy = true}
//}