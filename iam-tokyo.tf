# Create an IAM role that the Tokyo EC2 instance can assume.
resource "aws_iam_role" "tokyo_ec2" {
  provider = aws.tokyo

  name = "route53-geo-tokyo-ec2-role"

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
    Name    = "route53-geo-tokyo-ec2-role"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Attach the AWS-managed ECR read-only policy.
# This allows the EC2 instance to authenticate to ECR and pull Docker images.
resource "aws_iam_role_policy_attachment" "tokyo_ecr_readonly" {
  provider = aws.tokyo

  role       = aws_iam_role.tokyo_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Attach the Systems Manager policy.
# This allows us to manage the private EC2 instance using Session Manager
# without exposing SSH port 22 to the Internet.
resource "aws_iam_role_policy_attachment" "tokyo_ssm" {
  provider = aws.tokyo

  role       = aws_iam_role.tokyo_ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an instance profile so the IAM role can be attached to EC2.
resource "aws_iam_instance_profile" "tokyo_ec2" {
  provider = aws.tokyo

  name = "route53-geo-tokyo-ec2-profile"
  role = aws_iam_role.tokyo_ec2.name
}