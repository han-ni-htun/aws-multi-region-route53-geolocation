# Create an IAM role that the California EC2 instances can assume.
resource "aws_iam_role" "california_ec2" {
  provider = aws.california

  name = "route53-geo-california-ec2-role"

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
    Name    = "route53-geo-california-ec2-role"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Attach ECR read-only permissions so the California EC2 instances
# can authenticate to ECR and pull the Docker image.
resource "aws_iam_role_policy_attachment" "california_ecr_readonly" {
  provider = aws.california

  role       = aws_iam_role.california_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach Systems Manager permissions so we can manage
# the private EC2 instances without exposing SSH port 22.
resource "aws_iam_role_policy_attachment" "california_ssm" {
  provider = aws.california

  role       = aws_iam_role.california_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an instance profile so the California IAM role
# can be attached to the EC2 instances.
resource "aws_iam_instance_profile" "california_ec2" {
  provider = aws.california

  name = "route53-geo-california-ec2-profile"
  role = aws_iam_role.california_ec2.name
}