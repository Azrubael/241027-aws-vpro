# Создание Load Balancer
resource "aws_elb" "tomcat_elb" {
  name                  = "tomcat-elb"
  availability_zones    = data.aws_vpc.selected.availability_zones
  security_groups       = [ aws_security_group.sg_elb.id ]

  listener {
    instance_port       = 8080
    instance_protocol   = "HTTP"
    lb_port             = 80
    lb_protocol         = "HTTP"
  }
  health_check {
    target              = "HTTP:8080/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "Tomcat ELB"
  }
}

# Создание Launch Configuration для Autoscaling Group
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

# Создание Autoscaling Group
resource "aws_autoscaling_group" "tomcat_asg" {
  launch_configuration      = aws_launch_configuration.tomcat_lc.id
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = [local.sandbox_subnet_id]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                     = "Name"
    value                   = "Tomcat ASG Server"
    propagate_at_launch     = true
  }
}

# Создание политики масштабирования для увеличения
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.tomcat_asg.name
}

# Создание политики масштабирования для уменьшения
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.tomcat_asg.name
}

# Настройка целевого отслеживания для автоматического масштабирования
resource "aws_appautoscaling_target" "tomcat_target" {
  max_capacity          = 3
  min_capacity          = 1
  resource_id           = "autoScalingGroup:${aws_autoscaling_group.tomcat_asg.id}"
  scalable_dimension    = "autoscaling:autoScalingGroup:DesiredCapacity"
  service_namespace     = "aws:autoscaling"
}

resource "aws_appautoscaling_policy" "request_count_policy" {
  name                  = "request-count-policy"
  policy_type           = "TargetTrackingScaling"
  resource_id           = aws_appautoscaling_target.tomcat_target.id
  scalable_dimension    = aws_appautoscaling_target.tomcat_target.scalable_dimension
  service_namespace     = aws_appautoscaling_target.tomcat_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value        = 50
    scale_in_cooldown   = 300
    scale_out_cooldown  = 300

    predefined_metric_specification {
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${aws_alb.tomcat_alb.arn_suffix}/${aws_alb_target_group.tomcat_tg.arn_suffix}"
    }
  }

}

