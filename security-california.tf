# Create the security group for the California Application Load Balancer.
# The ALB accepts HTTP traffic from the Internet.
resource "aws_security_group" "california_alb" {
  provider = aws.california

  name        = "route53-geo-california-alb-sg"
  description = "Allow HTTP traffic from the Internet to the California ALB"
  vpc_id      = aws_vpc.california.id

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
    Name    = "route53-geo-california-alb-sg"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Create the security group for the California EC2 application instances.
# The EC2 instances accept application traffic only from the California ALB.
resource "aws_security_group" "california_ec2" {
  provider = aws.california

  name        = "route53-geo-california-ec2-sg"
  description = "Allow application traffic only from the California ALB"
  vpc_id      = aws_vpc.california.id

  # Allow the Docker application port only from the California ALB security group.
  ingress {
    description     = "Allow HTTP from the California ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.california_alb.id]
  }

  # Allow outbound traffic for Docker installation, ECR access, and SSM.
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "route53-geo-california-ec2-sg"
    Project = "route53-geolocation"
    Region  = "california"
  }
}