# Create the VPC for the California regional web stack.
resource "aws_vpc" "california" {
  provider = aws.california

  cidr_block           = "10.30.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "route53-geo-california-vpc"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Create the first public subnet in Availability Zone us-west-1a.
resource "aws_subnet" "california_public_a" {
  provider = aws.california

  vpc_id                  = aws_vpc.california.id
  cidr_block              = "10.30.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "route53-geo-california-public-a"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Create the second public subnet in Availability Zone us-west-1c.
resource "aws_subnet" "california_public_c" {
  provider = aws.california

  vpc_id                  = aws_vpc.california.id
  cidr_block              = "10.30.2.0/24"
  availability_zone       = "us-west-1c"
  map_public_ip_on_launch = true

  tags = {
    Name    = "route53-geo-california-public-c"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Create the first private subnet in Availability Zone us-west-1a.
resource "aws_subnet" "california_private_a" {
  provider = aws.california

  vpc_id            = aws_vpc.california.id
  cidr_block        = "10.30.11.0/24"
  availability_zone = "us-west-1a"

  tags = {
    Name    = "route53-geo-california-private-a"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Create the second private subnet in Availability Zone us-west-1c.
resource "aws_subnet" "california_private_c" {
  provider = aws.california

  vpc_id            = aws_vpc.california.id
  cidr_block        = "10.30.12.0/24"
  availability_zone = "us-west-1c"

  tags = {
    Name    = "route53-geo-california-private-c"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Create an Internet Gateway for the California VPC.
resource "aws_internet_gateway" "california" {
  provider = aws.california

  vpc_id = aws_vpc.california.id

  tags = {
    Name    = "route53-geo-california-igw"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Create the route table for both California public subnets.
resource "aws_route_table" "california_public" {
  provider = aws.california

  vpc_id = aws_vpc.california.id

  # Route Internet-bound IPv4 traffic through the Internet Gateway.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.california.id
  }

  tags = {
    Name    = "route53-geo-california-public-rt"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Associate California public subnet A with the public route table.
resource "aws_route_table_association" "california_public_a" {
  provider = aws.california

  subnet_id      = aws_subnet.california_public_a.id
  route_table_id = aws_route_table.california_public.id
}

# Associate California public subnet C with the public route table.
resource "aws_route_table_association" "california_public_c" {
  provider = aws.california

  subnet_id      = aws_subnet.california_public_c.id
  route_table_id = aws_route_table.california_public.id
}

# Create the route table for both California private subnets.
resource "aws_route_table" "california_private" {
  provider = aws.california

  vpc_id = aws_vpc.california.id

  tags = {
    Name    = "route53-geo-california-private-rt"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Associate California private subnet A with the private route table.
resource "aws_route_table_association" "california_private_a" {
  provider = aws.california

  subnet_id      = aws_subnet.california_private_a.id
  route_table_id = aws_route_table.california_private.id
}

# Associate California private subnet C with the private route table.
resource "aws_route_table_association" "california_private_c" {
  provider = aws.california

  subnet_id      = aws_subnet.california_private_c.id
  route_table_id = aws_route_table.california_private.id
}

# Allocate an Elastic IP address for the California NAT Gateway.
resource "aws_eip" "california_nat" {
  provider = aws.california

  domain = "vpc"

  tags = {
    Name    = "route53-geo-california-nat-eip"
    Project = "route53-geolocation"
    Region  = "california"
  }
}

# Create one NAT Gateway in California public subnet A.
# This provides outbound Internet access for both private subnets.
resource "aws_nat_gateway" "california" {
  provider = aws.california

  allocation_id = aws_eip.california_nat.id
  subnet_id     = aws_subnet.california_public_a.id

  tags = {
    Name    = "route53-geo-california-nat"
    Project = "route53-geolocation"
    Region  = "california"
  }

  depends_on = [
    aws_internet_gateway.california
  ]
}

# Route Internet-bound traffic from the California private subnets
# through the NAT Gateway.
resource "aws_route" "california_private_internet" {
  provider = aws.california

  route_table_id         = aws_route_table.california_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.california.id
}