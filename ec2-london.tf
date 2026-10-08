# Look up the latest Amazon Linux 2023 x86_64 AMI in London.
data "aws_ami" "amazon_linux_2023_london" {
  provider = aws.london

  most_recent = true
  owners      = ["amazon"]

  # Match the standard Amazon Linux 2023 x86_64 AMI.
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  # Require HVM virtualization.
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  # Require EBS-backed storage.
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# Define the two London application instances and their private subnets.
locals {
  london_web_instances = {
    a = {
      subnet_id = aws_subnet.london_private_a.id
      name      = "route53-geo-london-web-a"
    }

    b = {
      subnet_id = aws_subnet.london_private_b.id
      name      = "route53-geo-london-web-b"
    }
  }
}

# Create one London EC2 application instance in each private subnet.
resource "aws_instance" "london_web" {
  provider = aws.london

  for_each = local.london_web_instances

  ami           = data.aws_ami.amazon_linux_2023_london.id
  instance_type = "t3.micro"
  subnet_id     = each.value.subnet_id

  # Attach the security group that accepts application traffic
  # only from the London ALB.
  vpc_security_group_ids = [
    aws_security_group.london_ec2.id
  ]

  # Attach IAM permissions for ECR and Systems Manager.
  iam_instance_profile = aws_iam_instance_profile.london_ec2.name

  # Keep the instances private with no public IPv4 address.
  associate_public_ip_address = false

  # Install Docker, authenticate to ECR, pull the shared image,
  # and start the London version of the application.
  user_data = <<-EOF
    #!/bin/bash
    set -e

    # Update installed packages.
    yum update -y

    # Install Docker.
    yum install -y docker

    # Start Docker and enable it at boot.
    systemctl enable --now docker

    # Authenticate Docker to the Tokyo ECR registry.
    aws ecr get-login-password --region ap-northeast-1 | \
      docker login \
        --username AWS \
        --password-stdin \
        ${aws_ecr_repository.web_app.repository_url}

    # Pull version 1.0 of the shared application image.
    docker pull ${aws_ecr_repository.web_app.repository_url}:1.0

    # Run the London regional web application.
    docker run -d \
      --name route53-geolocation-web \
      --restart unless-stopped \
      -p 8080:8080 \
      -e LOCATION="London" \
      -e AWS_REGION="eu-west-2" \
      ${aws_ecr_repository.web_app.repository_url}:1.0
  EOF

  tags = {
    Name    = each.value.name
    Project = "route53-geolocation"
    Region  = "london"
  }
}