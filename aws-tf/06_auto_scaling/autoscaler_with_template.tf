resource "aws_launch_template" "vpro_app_template" {
  name_prefix   = "vpro-app-template"
  image_id      = var.OS_IMAGE_ID
  instance_type = "t2.micro"
  key_name      = "vpro-key"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.sg_front.id]
    subnet_id                   = local.sandbox_subnet_id
  }

  user_data = templatefile("${path.module}/vm-template-scripts/tomcat-template-script.sh", {
      db_ip              = var.DATABASE_IP
      mc_ip              = var.MEMCACHE_IP
      rmq_ip             = var.RABBITMQ_IP
      S3_BUCKET_NAME     = var.BUCKET_NAME
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "tomcat_asg" {
  launch_template {
    id      = aws_launch_template.vpro_app_template.id
    version = "$Latest"
  }

  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = [local.sandbox_subnet_id]
  health_check_type         = "ELB"
  health_check_grace_period = 60 

  tag {
    key                     = "Name"
    value                   = "Tomcat ASG Server"
    propagate_at_launch     = true
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1   # Scale up by 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120 
  autoscaling_group_name = aws_autoscaling_group.tomcat_asg.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1  # Scale down by 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120 
  autoscaling_group_name = aws_autoscaling_group.tomcat_asg.name
}

resource "aws_appautoscaling_target" "front_end" {
  max_capacity          = 3
  min_capacity          = 1
  resource_id           = "autoScalingGroup:${aws_autoscaling_group.tomcat_asg.id}"
  scalable_dimension    = "autoscaling:autoScalingGroup:DesiredCapacity"
  service_namespace     = "aws:autoscaling"
}

resource "aws_appautoscaling_policy" "tomcat_asg_policy" {
  name                  = "request-count-policy"
  policy_type           = "TargetTrackingScaling"
  resource_id           = aws_appautoscaling_target.front_end.id
  scalable_dimension    = aws_appautoscaling_target.front_end.scalable_dimension
  service_namespace     = aws_appautoscaling_target.front_end.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value        = 50  # % of requests to track
    scale_in_cooldown   = 120 
    scale_out_cooldown  = 120 

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_alb.front_end.arn_suffix}/${aws_alb_target_group.front_end.arn_suffix}"
    }
  }
}
