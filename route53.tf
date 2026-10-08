# Create a public Route 53 hosted zone for the project domain.
resource "aws_route53_zone" "main" {
  provider = aws.tokyo

  name = "hannihtun.com"

  tags = {
    Name    = "hannihtun.com"
    Project = "route53-geolocation"
  }
}

# Route users located in Asia to the Tokyo Application Load Balancer.
resource "aws_route53_record" "geo_asia" {
  provider = aws.tokyo

  zone_id = aws_route53_zone.main.zone_id
  name    = "geo.hannihtun.com"
  type    = "A"

  # Give this geolocation record a unique identifier.
  set_identifier = "asia-tokyo"

  # Apply this record to users whose DNS location is in Asia.
  geolocation_routing_policy {
    continent = "AS"
  }

  # Point the Route 53 record to the Tokyo ALB using an alias.
  alias {
    name                   = aws_lb.tokyo.dns_name
    zone_id                = aws_lb.tokyo.zone_id
    evaluate_target_health = true
  }
}

# Route users located in Europe to the London Application Load Balancer.
resource "aws_route53_record" "geo_europe" {
  provider = aws.tokyo

  zone_id = aws_route53_zone.main.zone_id
  name    = "geo.hannihtun.com"
  type    = "A"

  # Give this geolocation record a unique identifier.
  set_identifier = "europe-london"

  # Apply this record to users whose DNS location is in Europe.
  geolocation_routing_policy {
    continent = "EU"
  }

  # Point the Route 53 record to the London ALB using an alias.
  alias {
    name                   = aws_lb.london.dns_name
    zone_id                = aws_lb.london.zone_id
    evaluate_target_health = true
  }
}

# Route users located in North America to the California Application Load Balancer.
resource "aws_route53_record" "geo_north_america" {
  provider = aws.tokyo

  zone_id = aws_route53_zone.main.zone_id
  name    = "geo.hannihtun.com"
  type    = "A"

  # Give this geolocation record a unique identifier.
  set_identifier = "north-america-california"

  # Apply this record to users whose DNS location is in North America.
  geolocation_routing_policy {
    continent = "NA"
  }

  # Point the Route 53 record to the California ALB using an alias.
  alias {
    name                   = aws_lb.california.dns_name
    zone_id                = aws_lb.california.zone_id
    evaluate_target_health = true
  }
}

# Create a default geolocation record for users who do not match
# any of the explicitly configured continent routing rules.
resource "aws_route53_record" "geo_default" {
  provider = aws.tokyo

  zone_id = aws_route53_zone.main.zone_id
  name    = "geo.hannihtun.com"
  type    = "A"

  # Give the default geolocation record a unique identifier.
  set_identifier = "default-tokyo"

  # The wildcard country code creates the default geolocation record.
  geolocation_routing_policy {
    country = "*"
  }

  # Send unmatched users to the Tokyo ALB.
  alias {
    name                   = aws_lb.tokyo.dns_name
    zone_id                = aws_lb.tokyo.zone_id
    evaluate_target_health = true
  }
}