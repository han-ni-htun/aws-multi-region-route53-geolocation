# Create an Amazon ECR repository to store the Docker image
# used by the regional web application.
resource "aws_ecr_repository" "web_app" {
  provider = aws.tokyo

  name                 = "route53-geolocation-web"
  image_tag_mutability = "MUTABLE"

  # Enable image scanning when a new image is pushed.
  image_scanning_configuration {
    scan_on_push = true
  }

  # Prevent Terraform from accidentally deleting the repository
  # while it contains the Docker image used by this project.
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name    = "route53-geolocation-web"
    Project = "route53-geolocation"
  }
}