# Create the security group for the London Application Load Balancer.
# The ALB accepts HTTP traffic from the Internet.
resource "aws_security_group" "london_alb" {
  provider = aws.london

  name        = "route53-geo-london-alb-sg"
  description = "Allow HTTP traffic from the Internet to the London ALB"
  vpc_id      = aws_vpc.london.id

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
    Name    = "route53-geo-london-alb-sg"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Create the security group for the London EC2 application instances.
# The EC2 instances accept application traffic only from the London ALB.
resource "aws_security_group" "london_ec2" {
  provider = aws.london

  name        = "route53-geo-london-ec2-sg"
  description = "Allow application traffic only from the London ALB"
  vpc_id      = aws_vpc.london.id

  # Allow the Docker application port only from the London ALB security group.
  ingress {
    description     = "Allow HTTP from the London ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.london_alb.id]
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
    Name    = "route53-geo-london-ec2-sg"
    Project = "route53-geolocation"
    Region  = "london"
  }
}