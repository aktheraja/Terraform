resource "aws_alb_target_group" "alb_target_group_1" {
  name_prefix    = "targp-"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc_environment.id


  tags = {
    name = "alb_target_group2"
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 1800
    enabled         = true
  }
  slow_start = 0
  deregistration_delay = 30
  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 2
    interval            = 5
    path                = "/"
    port                = 80
  }
  lifecycle {create_before_destroy = true}

}

resource "aws_alb" "alb" {
  name_prefix = "lbnik-"
//  subnets = [
//    aws_subnet.public_subnet1.id,
//    aws_subnet.public_subnet2.id]
  subnets =aws_subnet.public_subnet.*.id
  security_groups = [
    aws_security_group.security.id]
  internal = false

  idle_timeout = 2
  tags = {
    Name = "alb2"
  }
  lifecycle {create_before_destroy = true}
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.alb_target_group_1.arn
    type             = "forward"
  }
  lifecycle {create_before_destroy = true}
}
