//resource "aws_ecs_service" "test-ecs-service" {
//  	name            = "test-ecs-service"
//  	iam_role        = "arn:aws:iam::632199730033:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
//  	cluster         = aws_ecs_cluster.test-ecs-cluster.id
//  	task_definition = "${aws_ecs_task_definition.wordpress.family}:${max("${aws_ecs_task_definition.wordpress.revision}", "${data.aws_ecs_task_definition.wordpress.revision}")}"
//  	desired_count   = 1
////	depends_on = aws_alb.ecs-load-balancer
//
//  	load_balancer {
//    	target_group_arn  = aws_alb_target_group.ecs-target-group.arn
//    	container_port    = 80
//    	container_name    = "wordpress"
//	}
//}

//resource "null_resource" "alb_exists" {
//	triggers {
//		alb_name = aws_alb.ecs-load-balancer.arn
//	}
//}

resource "aws_ecs_service" "test-ecs-service" {
	name            = "mongodb"
	cluster         = aws_ecs_cluster.test-ecs-cluster.id
	task_definition = "${aws_ecs_task_definition.wordpress.family}:${max("${aws_ecs_task_definition.wordpress.revision}", "${data.aws_ecs_task_definition.wordpress.revision}")}"
	  	desired_count   = 1
	iam_role        = "arn:aws:iam::632199730033:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS"
//	depends_on      = ["aws_iam_role_policy.foo"]
	depends_on = [aws_iam_role_policy_attachment.ecs-service-role-attachment]
	ordered_placement_strategy {
		type  = "binpack"
		field = "cpu"
	}

	load_balancer {
		target_group_arn = aws_alb_target_group.ecs-target-group.arn
		container_name   = "wordpress"
		container_port   = 80
	}

	placement_constraints {
		type       = "memberOf"
		expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
	}
}