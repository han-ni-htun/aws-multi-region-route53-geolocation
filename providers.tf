# Configure the Terraform version and AWS provider version
terraform {
  required_version = ">= 1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS provider for the Tokyo region
provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

# Configure the AWS provider for the London region
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

# Configure the AWS provider for the California region
provider "aws" {
  alias  = "california"
  region = "us-west-1"
}