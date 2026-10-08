# Look up the latest Amazon Linux 2023 x86_64 AMI published by AWS.
data "aws_ami" "amazon_linux_2023_tokyo" {
  provider = aws.tokyo

  most_recent = true
  owners      = ["amazon"]

  # Match the standard Amazon Linux 2023 x86_64 EBS-backed AMI.
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  # Ensure the selected image uses HVM virtualization.
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Ensure the selected image uses EBS-backed storage.
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Define the Tokyo application instances and the private subnet
# where each instance should be created.
locals {
  tokyo_web_instances = {
    a = {
      subnet_id = aws_subnet.tokyo_private_a.id
      name      = "route53-geo-tokyo-web-a"
    }

    c = {
      subnet_id = aws_subnet.tokyo_private_c.id
      name      = "route53-geo-tokyo-web-c"
    }
  }
}

# Create one Tokyo application EC2 instance in each private subnet.
resource "aws_instance" "tokyo_web" {
  provider = aws.tokyo

  for_each = local.tokyo_web_instances

  ami           = data.aws_ami.amazon_linux_2023_tokyo.id
  instance_type = "t3.micro"
  subnet_id     = each.value.subnet_id

  # Attach the EC2 security group that allows application traffic
  # only from the Tokyo ALB.
  vpc_security_group_ids = [
    aws_security_group.tokyo_ec2.id
  ]

  # Attach the IAM instance profile for ECR read access and SSM.
  iam_instance_profile = aws_iam_instance_profile.tokyo_ec2.name

  # Do not assign a public IP because the instance is private.
  associate_public_ip_address = false

  # Bootstrap Docker and run the Tokyo container from ECR.
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update installed packages.
    yum update -y

    # Install Docker.
    yum install -y docker

    # Start Docker and enable it at boot.
    systemctl enable --now docker

    # Authenticate Docker to Amazon ECR.
    aws ecr get-login-password --region ap-northeast-1 | \
      docker login \
        --username AWS \
        --password-stdin \
        ${aws_ecr_repository.web_app.repository_url}

    # Pull version 1.0 of the application image.
    docker pull ${aws_ecr_repository.web_app.repository_url}:1.0

    # Run the Tokyo regional web application.
    docker run -d \
      --name route53-geolocation-web \
      --restart unless-stopped \
      -p 8080:8080 \
      -e LOCATION="Tokyo" \
      -e AWS_REGION="ap-northeast-1" \
      ${aws_ecr_repository.web_app.repository_url}:1.0
  EOF

  tags = {
    Name    = each.value.name
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}