# Create the Tokyo Application Load Balancer in both public subnets.
resource "aws_lb" "tokyo" {
  provider = aws.tokyo

  name               = "route53-geo-tokyo-alb"
  internal           = false
  load_balancer_type = "application"

  # Attach the ALB security group that allows inbound HTTP traffic.
  security_groups = [
    aws_security_group.tokyo_alb.id
  ]

  # Place the internet-facing ALB across both public subnets.
  subnets = [
    aws_subnet.tokyo_public_a.id,
    aws_subnet.tokyo_public_c.id
  ]

  tags = {
    Name    = "route53-geo-tokyo-alb"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Create the target group used by the Tokyo ALB.
# The ALB forwards traffic to the Docker application on port 8080.
resource "aws_lb_target_group" "tokyo_web" {
  provider = aws.tokyo

  name        = "route53-geo-tokyo-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.tokyo.id

  # Check the root path of the application to determine target health.
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
    Name    = "route53-geo-tokyo-tg"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Register both Tokyo EC2 instances with the target group.
# Use the statically defined instance map so Terraform knows the keys
# before the EC2 instances are created.
resource "aws_lb_target_group_attachment" "tokyo_web" {
  provider = aws.tokyo

  for_each = local.tokyo_web_instances

  target_group_arn = aws_lb_target_group.tokyo_web.arn
  target_id        = aws_instance.tokyo_web[each.key].id
  port             = 8080
}

# Create an HTTP listener on port 80 for the Tokyo ALB.
# All incoming HTTP requests are forwarded to the Tokyo target group.
resource "aws_lb_listener" "tokyo_http" {
  provider = aws.tokyo

  load_balancer_arn = aws_lb.tokyo.arn
  port              = 80
  protocol          = "HTTP"

  # Forward incoming requests to both Tokyo EC2 targets.
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tokyo_web.arn
  }
}