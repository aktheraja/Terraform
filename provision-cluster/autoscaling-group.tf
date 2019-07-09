
resource "aws_autoscaling_group" "ecs-autoscaling-group" {
    name                        = "ecs-autoscaling-group-Craig"
    max_size                    = var.az_count*3
    min_size                    = var.az_count
    //desired_capacity            = 3
    vpc_zone_identifier         = [aws_subnet.private_sn.id]
    launch_configuration        = aws_launch_configuration.ecs-launch-configuration.name
    tag {
        key                 = "Name"
        value               = "auto_scale"
        propagate_at_launch = true
    }
    health_check_grace_period = 1
    health_check_type = "ELB"
    lifecycle {create_before_destroy = true}
    enabled_metrics = []
  }
