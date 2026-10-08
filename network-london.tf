# Create the VPC for the London regional web stack.
resource "aws_vpc" "london" {
  provider = aws.london

  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "route53-geo-london-vpc"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Create the first public subnet in Availability Zone eu-west-2a.
resource "aws_subnet" "london_public_a" {
  provider = aws.london

  vpc_id                  = aws_vpc.london.id
  cidr_block              = "10.20.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "route53-geo-london-public-a"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Create the second public subnet in Availability Zone eu-west-2b.
resource "aws_subnet" "london_public_b" {
  provider = aws.london

  vpc_id                  = aws_vpc.london.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name    = "route53-geo-london-public-b"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Create the first private subnet in Availability Zone eu-west-2a.
resource "aws_subnet" "london_private_a" {
  provider = aws.london

  vpc_id            = aws_vpc.london.id
  cidr_block        = "10.20.11.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name    = "route53-geo-london-private-a"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Create the second private subnet in Availability Zone eu-west-2b.
resource "aws_subnet" "london_private_b" {
  provider = aws.london

  vpc_id            = aws_vpc.london.id
  cidr_block        = "10.20.12.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name    = "route53-geo-london-private-b"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Create an Internet Gateway for the London VPC.
resource "aws_internet_gateway" "london" {
  provider = aws.london

  vpc_id = aws_vpc.london.id

  tags = {
    Name    = "route53-geo-london-igw"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Create the route table used by both London public subnets.
resource "aws_route_table" "london_public" {
  provider = aws.london

  vpc_id = aws_vpc.london.id

  # Route Internet-bound IPv4 traffic through the Internet Gateway.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.london.id
  }

  tags = {
    Name    = "route53-geo-london-public-rt"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Associate London public subnet A with the public route table.
resource "aws_route_table_association" "london_public_a" {
  provider = aws.london

  subnet_id      = aws_subnet.london_public_a.id
  route_table_id = aws_route_table.london_public.id
}

# Associate London public subnet B with the public route table.
resource "aws_route_table_association" "london_public_b" {
  provider = aws.london

  subnet_id      = aws_subnet.london_public_b.id
  route_table_id = aws_route_table.london_public.id
}

# Create the route table used by both London private subnets.
resource "aws_route_table" "london_private" {
  provider = aws.london

  vpc_id = aws_vpc.london.id

  tags = {
    Name    = "route53-geo-london-private-rt"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Associate London private subnet A with the private route table.
resource "aws_route_table_association" "london_private_a" {
  provider = aws.london

  subnet_id      = aws_subnet.london_private_a.id
  route_table_id = aws_route_table.london_private.id
}

# Associate London private subnet B with the private route table.
resource "aws_route_table_association" "london_private_b" {
  provider = aws.london

  subnet_id      = aws_subnet.london_private_b.id
  route_table_id = aws_route_table.london_private.id
}

# Allocate an Elastic IP address for the London NAT Gateway.
resource "aws_eip" "london_nat" {
  provider = aws.london

  domain = "vpc"

  tags = {
    Name    = "route53-geo-london-nat-eip"
    Project = "route53-geolocation"
    Region  = "london"
  }
}

# Create one NAT Gateway in London public subnet A.
# This provides outbound connectivity for instances in both private subnets.
resource "aws_nat_gateway" "london" {
  provider = aws.london

  allocation_id = aws_eip.london_nat.id
  subnet_id     = aws_subnet.london_public_a.id

  tags = {
    Name    = "route53-geo-london-nat"
    Project = "route53-geolocation"
    Region  = "london"
  }

  depends_on = [
    aws_internet_gateway.london
  ]
}

# Route Internet-bound traffic from the London private subnets
# through the NAT Gateway.
resource "aws_route" "london_private_internet" {
  provider = aws.london

  route_table_id         = aws_route_table.london_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.london.id
}