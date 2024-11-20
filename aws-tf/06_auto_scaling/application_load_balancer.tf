# Create a target group
resource "aws_alb_target_group" "front_end" {
  name     = "tomcat-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    path                = "/"
  }
}


# Create an AWS Application Load Balancer
resource "aws_alb" "front_end" {
  name                       = "tomcat-alb-tf"
  load_balancer_type         = "application"
  internal                   = false
  enable_deletion_protection = false
  
  subnets         = [ 
    local.sandbox_subnet_id,
    local.sandbox_subnet16_id
  ]

  security_groups = [
    aws_security_group.sg_alb.id
  ]

  tags = {
    Name = "Tomcat ALB"
  }
}


# Create an ALB listener
resource "aws_alb_listener" "front_end" {
  load_balancer_arn     = aws_alb.front_end.arn
  port                  = 80
  protocol              = "HTTP"

  default_action {
    type                = "forward"
    target_group_arn    = aws_alb_target_group.front_end.arn
  }
}
