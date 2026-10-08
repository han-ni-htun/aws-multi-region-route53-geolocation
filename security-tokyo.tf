# Create the security group for the Tokyo Application Load Balancer.
# The ALB accepts HTTP traffic from the Internet.
resource "aws_security_group" "tokyo_alb" {
  provider = aws.tokyo

  name        = "route53-geo-tokyo-alb-sg"
  description = "Allow HTTP traffic from the Internet to the Tokyo ALB"
  vpc_id      = aws_vpc.tokyo.id

  # Allow inbound HTTP traffic from anywhere.
  ingress {
    description = "Allow HTTP from the Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic from the ALB.
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "route53-geo-tokyo-alb-sg"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Create the security group for the Tokyo EC2 application instances.
# The EC2 instances accept application traffic only from the ALB.
resource "aws_security_group" "tokyo_ec2" {
  provider = aws.tokyo

  name        = "route53-geo-tokyo-ec2-sg"
  description = "Allow application traffic only from the Tokyo ALB"
  vpc_id      = aws_vpc.tokyo.id

  # Allow HTTP traffic to the application only from the ALB security group.
  ingress {
    description     = "Allow HTTP from the Tokyo ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.tokyo_alb.id]
  }

  # Allow all outbound traffic so the private EC2 instance can reach
  # package repositories and ECR through the NAT Gateway.
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "route53-geo-tokyo-ec2-sg"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}