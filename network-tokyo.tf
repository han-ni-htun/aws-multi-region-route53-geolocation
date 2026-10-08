# Create the VPC for the Tokyo regional web stack.
resource "aws_vpc" "tokyo" {
  provider = aws.tokyo

  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "route53-geo-tokyo-vpc"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Create the first public subnet in Availability Zone ap-northeast-1a.
resource "aws_subnet" "tokyo_public_a" {
  provider = aws.tokyo

  vpc_id                  = aws_vpc.tokyo.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "route53-geo-tokyo-public-a"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Create the second public subnet in Availability Zone ap-northeast-1c.
resource "aws_subnet" "tokyo_public_c" {
  provider = aws.tokyo

  vpc_id                  = aws_vpc.tokyo.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true

  tags = {
    Name    = "route53-geo-tokyo-public-c"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Create an Internet Gateway and attach it to the Tokyo VPC.
resource "aws_internet_gateway" "tokyo" {
  provider = aws.tokyo

  vpc_id = aws_vpc.tokyo.id

  tags = {
    Name    = "route53-geo-tokyo-igw"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Create a route table for the Tokyo public subnets.
resource "aws_route_table" "tokyo_public" {
  provider = aws.tokyo

  vpc_id = aws_vpc.tokyo.id

  # Route all IPv4 Internet traffic through the Internet Gateway.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tokyo.id
  }

  tags = {
    Name    = "route53-geo-tokyo-public-rt"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Associate the first Tokyo public subnet with the public route table.
resource "aws_route_table_association" "tokyo_public_a" {
  provider = aws.tokyo

  subnet_id      = aws_subnet.tokyo_public_a.id
  route_table_id = aws_route_table.tokyo_public.id
}

# Associate the second Tokyo public subnet with the public route table.
resource "aws_route_table_association" "tokyo_public_c" {
  provider = aws.tokyo

  subnet_id      = aws_subnet.tokyo_public_c.id
  route_table_id = aws_route_table.tokyo_public.id
}

# Create the first private subnet in Availability Zone ap-northeast-1a.
resource "aws_subnet" "tokyo_private_a" {
  provider = aws.tokyo

  vpc_id            = aws_vpc.tokyo.id
  cidr_block        = "10.10.11.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name    = "route53-geo-tokyo-private-a"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Create the second private subnet in Availability Zone ap-northeast-1c.
resource "aws_subnet" "tokyo_private_c" {
  provider = aws.tokyo

  vpc_id            = aws_vpc.tokyo.id
  cidr_block        = "10.10.12.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name    = "route53-geo-tokyo-private-c"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Create a route table for the Tokyo private subnets.
# No default Internet route is added yet.
resource "aws_route_table" "tokyo_private" {
  provider = aws.tokyo

  vpc_id = aws_vpc.tokyo.id

  tags = {
    Name    = "route53-geo-tokyo-private-rt"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Associate the first Tokyo private subnet with the private route table.
resource "aws_route_table_association" "tokyo_private_a" {
  provider = aws.tokyo

  subnet_id      = aws_subnet.tokyo_private_a.id
  route_table_id = aws_route_table.tokyo_private.id
}

# Associate the second Tokyo private subnet with the private route table.
resource "aws_route_table_association" "tokyo_private_c" {
  provider = aws.tokyo

  subnet_id      = aws_subnet.tokyo_private_c.id
  route_table_id = aws_route_table.tokyo_private.id
}

# Allocate an Elastic IP address for the Tokyo NAT Gateway.
resource "aws_eip" "tokyo_nat" {
  provider = aws.tokyo

  domain = "vpc"

  tags = {
    Name    = "route53-geo-tokyo-nat-eip"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }
}

# Create a NAT Gateway in the first Tokyo public subnet.
# Private EC2 instances will use this gateway for outbound Internet access.
resource "aws_nat_gateway" "tokyo" {
  provider = aws.tokyo

  allocation_id = aws_eip.tokyo_nat.id
  subnet_id     = aws_subnet.tokyo_public_a.id

  tags = {
    Name    = "route53-geo-tokyo-nat"
    Project = "route53-geolocation"
    Region  = "tokyo"
  }

  depends_on = [
    aws_internet_gateway.tokyo
  ]
}

# Add a default route from the Tokyo private route table to the NAT Gateway.
# This allows private instances to reach the Internet without being directly reachable from it.
resource "aws_route" "tokyo_private_internet" {
  provider = aws.tokyo

  route_table_id         = aws_route_table.tokyo_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tokyo.id
}