# Create the London Application Load Balancer across both public subnets.
resource "aws_lb" "london" {
  provider = aws.london

  name               = "route53-geo-london-alb"
  internal           = false
  load_balancer_type = "application"

  # Attach the security group that allows HTTP traffic from the Internet.
  security_groups = [
    aws_security_group.london_alb.id
  ]

  # Deploy the ALB across two Availability Zones.
  subnets = [
    aws_subnet.london_public_a.id,
    aws_subnet.london_public_b.id
  ]

  tags = {
    Name    = "route53-geo-london-alb"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Create the target group for the London Docker application.
resource "aws_lb_target_group" "london_web" {
  provider = aws.london

  name        = "route53-geo-london-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.london.id

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
    Name    = "route53-geo-london-tg"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Register both London EC2 instances with the target group.
# Use the statically defined instance map so Terraform knows the keys
# before the EC2 instances are created.
resource "aws_lb_target_group_attachment" "london_web" {
  provider = aws.london

  for_each = local.london_web_instances

  target_group_arn = aws_lb_target_group.london_web.arn
  target_id        = aws_instance.london_web[each.key].id
  port             = 8080
}

# Create an HTTP listener for the London ALB.
resource "aws_lb_listener" "london_http" {
  provider = aws.london

  load_balancer_arn = aws_lb.london.arn
  port              = 80
  protocol          = "HTTP"

  # Forward incoming HTTP requests to the London target group.
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.london_web.arn
  }
}