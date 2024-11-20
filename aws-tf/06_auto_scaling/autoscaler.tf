# Create Launch Configuration for TomCat Autoscaling Group `tomcat_asg`
resource "aws_launch_configuration" "tomcat_lc" {
  name                 = "tomcat-launch-conf"
  image_id             = var.OS_IMAGE_ID
  instance_type        = "t2.micro"
  key_name             = "vpro-key"
  security_groups      = [ aws_security_group.sg_front.id ]

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


# Create Autoscaling Group
resource "aws_autoscaling_group" "tomcat_asg" {
  launch_configuration      = aws_launch_configuration.tomcat_lc.id
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = [local.sandbox_subnet_id]
  health_check_type         = "ELB"
  health_check_grace_period = 60 # seconds

  tag {
    key                     = "Name"
    value                   = "Tomcat ASG Server"
    propagate_at_launch     = true
  }
}


# Create autoscaling policy to scale out
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1   # Scale up by 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120 # seconds
  autoscaling_group_name = aws_autoscaling_group.tomcat_asg.name
}


# Create autoscaling policy to scale in
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1  # Scale down by 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120 # seconds
  autoscaling_group_name = aws_autoscaling_group.tomcat_asg.name
}


# Setup Target Tracking Scaling
resource "aws_appautoscaling_target" "front_end" {
  max_capacity          = 3
  min_capacity          = 1
  resource_id           = "autoScalingGroup:${aws_autoscaling_group.tomcat_asg.id}"
  scalable_dimension    = "autoscaling:autoScalingGroup:DesiredCapacity"
  service_namespace     = "aws:autoscaling"
}


# Define an application autoscaling policy
resource "aws_appautoscaling_policy" "tomcat_asg_policy" {
  name                  = "request-count-policy"
  policy_type           = "TargetTrackingScaling"
  resource_id           = aws_appautoscaling_target.front_end.id
  scalable_dimension    = aws_appautoscaling_target.front_end.scalable_dimension
  service_namespace     = aws_appautoscaling_target.front_end.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value        = 50  # % of requests to track
    scale_in_cooldown   = 120 # seconds
    scale_out_cooldown  = 120 # seconds

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_alb.front_end.arn_suffix}/${aws_alb_target_group.front_end.arn_suffix}"
    }
  }

}

