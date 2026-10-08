# Create the California Application Load Balancer across both public subnets.
resource "aws_lb" "california" {
  provider = aws.california

  name               = "route53-geo-california-alb"
  internal           = false
  load_balancer_type = "application"

  # Attach the security group that allows HTTP traffic from the Internet.
  security_groups = [
    aws_security_group.california_alb.id
  ]

  # Deploy the ALB across two Availability Zones.
  subnets = [
    aws_subnet.california_public_a.id,
    aws_subnet.california_public_c.id
  ]

  tags = {
    Name    = "route53-geo-california-alb"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Create the target group for the California Docker application.
resource "aws_lb_target_group" "california_web" {
  provider = aws.california

  name        = "route53-geo-california-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.california.id

  # Check the application's root path on port 8080.
  health_check {
    enabled             = true
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = {
    Name    = "route53-geo-california-tg"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Register both California EC2 instances with the target group.
# Use the statically defined instance map so Terraform knows the keys
# before the EC2 instances are created.
resource "aws_lb_target_group_attachment" "california_web" {
  provider = aws.california

  for_each = local.california_web_instances

  target_group_arn = aws_lb_target_group.california_web.arn
  target_id        = aws_instance.california_web[each.key].id
  port             = 8080
}

# Create an HTTP listener for the California ALB.
resource "aws_lb_listener" "california_http" {
  provider = aws.california

  load_balancer_arn = aws_lb.california.arn
  port              = 80
  protocol          = "HTTP"

  # Forward incoming HTTP requests to the California target group.
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.california_web.arn
  }
}