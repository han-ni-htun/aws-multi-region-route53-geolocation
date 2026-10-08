# Create an IAM role that the London EC2 instances can assume.
resource "aws_iam_role" "london_ec2" {
  provider = aws.london

  name = "route53-geo-london-ec2-role"

  # Allow the EC2 service to assume this IAM role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name    = "route53-geo-london-ec2-role"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Attach ECR read-only permissions so London EC2 instances
# can authenticate to ECR and pull the Docker image.
resource "aws_iam_role_policy_attachment" "london_ecr_readonly" {
  provider = aws.london

  role       = aws_iam_role.london_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach Systems Manager permissions so we can access
# the private EC2 instances without exposing SSH port 22.
resource "aws_iam_role_policy_attachment" "london_ssm" {
  provider = aws.london

  role       = aws_iam_role.london_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an instance profile so the London IAM role
# can be attached to the EC2 instances.
resource "aws_iam_instance_profile" "london_ec2" {
  provider = aws.london

  name = "route53-geo-london-ec2-profile"
  role = aws_iam_role.london_ec2.name
}