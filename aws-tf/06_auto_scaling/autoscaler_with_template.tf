# Create a Launch Template for TomCat Autoscaling Group `tomcat_asg`
resource "aws_launch_template" "vpro_app_template" {
  name_prefix   = "vpro-app-template"
  image_id      = var.OS_IMAGE_ID
  instance_type = "t2.micro"
  key_name      = "vpro-key"

  iam_instance_profile {
    name = module.instance_profile_setup.instance_profile_name 
  }

  network_interfaces {
    associate_public_ip_address = false #true
    security_groups             = [ aws_security_group.sg_front.id ]
    subnet_id                   = local.sandbox_subnet_id
  }

  user_data = base64encode(templatefile("${path.module}/vm-template-scripts/tomcat-template-script.sh", {
      db_ip              = var.DATABASE_IP
      mc_ip              = var.MEMCACHE_IP
      rmq_ip             = var.RABBITMQ_IP
      S3_BUCKET_NAME     = var.BUCKET_NAME
    }
  ))
  
  tags = {
    Name      = "Vpro App Instance"
    Project   = "vpro"
    Server    = "TomCat"
  }

  lifecycle {
    create_before_destroy = true
  }
}


# Create Autoscaling Group
resource "aws_autoscaling_group" "tomcat_asg" {
  name                      = "vpro-app-asg"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  vpc_zone_identifier       = [ local.sandbox_subnet_id ]
  health_check_type         = "ELB"
  health_check_grace_period = 60 # seconds

  launch_template {
    id      = aws_launch_template.vpro_app_template.id
    version = "$Latest"
  }

  tag {
    key                     = "Name"
    value                   = "Tomcat ASG Server"
    propagate_at_launch     = true
  }
}


# Create autoscaling policy to scale out
resource "aws_autoscaling_policy" "tomcat_asg_scale_out" {
  name                   = "scale-out"
  scaling_adjustment     = 1   # Scale up by 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120 # seconds
  autoscaling_group_name = aws_autoscaling_group.tomcat_asg.name
}


# Create autoscaling policy to scale in
resource "aws_autoscaling_policy" "tomcat_asg_scale_in" {
  name                   = "scale-in"
  scaling_adjustment     = -1  # Scale down by 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120 
  autoscaling_group_name = aws_autoscaling_group.tomcat_asg.name
}


resource "aws_cloudwatch_metric_alarm" "high_request_count" {
  alarm_name          = "high-request-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "RequestCount"
  namespace          = "AWS/ApplicationELB"
  period             = "30"
  statistic          = "Sum"
  threshold          = 50
  alarm_description  = "This metric monitors ALB request count"
  dimensions = { LoadBalancer = aws_alb.front_end.dns_name }

  alarm_actions = [ aws_autoscaling_policy.tomcat_asg_scale_out.arn ]
}

resource "aws_cloudwatch_metric_alarm" "low_request_count" {
  alarm_name          = "low-request-count"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name        = "RequestCount"
  namespace          = "AWS/ApplicationELB"
  period             = "30"
  statistic          = "Sum"
  threshold          = 10
  alarm_description  = "This metric monitors ALB request count"
  dimensions = { LoadBalancer = aws_alb.front_end.dns_name }

  alarm_actions = [ aws_autoscaling_policy.tomcat_asg_scale_in.arn ]
}
