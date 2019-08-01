resource "aws_launch_configuration" "autoscale_launch_config" {
  name_prefix          = "autoscale_launcher-nikky-"
  image_id        = var.ami
  instance_type   = "t2.nano"
  //  key_name        = var.ami_key_pair_name
  security_groups = [aws_security_group.security.id]
  enable_monitoring = true
  user_data = file(
  "/Users/yujiacui/Desktop/install_apache_server.sh"

  )
  lifecycle {create_before_destroy = true}
}

resource "aws_autoscaling_group" "autoscale_group_1" {
  name_prefix="asg-${aws_launch_configuration.autoscale_launch_config.name}"
  launch_configuration = aws_launch_configuration.autoscale_launch_config.id
//  vpc_zone_identifier  =[aws_subnet.public_subnet.*.id[count.index],aws_subnet.private_subnet.*.id[count.index]]
  vpc_zone_identifier  =aws_subnet.private_subnet.*.id
  min_size = var.min_asg
  max_size = var.max_asg
  desired_capacity = var.des_asg
  wait_for_elb_capacity = 3

  tag {
    key                 = "Name"
    value               = "auto_scale-Nikky"
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
  metrics_granularity="1Minute"
//  provisioner "local-exec" {
//    command = "check_health.sh ${aws_alb.alb.dns_name} asg-autoscale_launcher-nikky-20190731200646732400000001 aws_alb_target_group.alb_target_group_1.arn"
//  }
}
locals {
  ASGname=aws_autoscaling_group.autoscale_group_1.*.name
}

resource "aws_autoscaling_attachment" "alb_autoscale" {
  count = length(split(",",var.availability_zones))
  alb_target_group_arn   = aws_alb_target_group.alb_target_group_1.arn
  autoscaling_group_name = aws_autoscaling_group.autoscale_group_1.id
  lifecycle {create_before_destroy = true}

//  provisioner "local-exec" {
//    command = "attchmnt_checkhealth.sh asg-autoscale_launcher-nikky-20190725064518336300000001 ${aws_alb_target_group.alb_target_group_1.arn}"
//  }

}
