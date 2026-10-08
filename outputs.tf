# Output the Route 53 hosted zone ID for reference and troubleshooting.
output "route53_hosted_zone_id" {
  description = "Route 53 public hosted zone ID for hannihtun.com"
  value       = aws_route53_zone.main.zone_id
}

# Output the authoritative Route 53 name servers for the public hosted zone.
output "route53_name_servers" {
  description = "Authoritative Route 53 name servers for hannihtun.com"
  value       = aws_route53_zone.main.name_servers
}

# Output the public DNS name used to test geolocation routing.
output "geolocation_url" {
  description = "Public DNS name for the Route 53 geolocation demo"
  value       = "http://geo.hannihtun.com"
}

# Output the Tokyo ALB DNS name for reference and troubleshooting.
output "tokyo_alb_dns" {
  description = "DNS name of the Tokyo Application Load Balancer"
  value       = aws_lb.tokyo.dns_name
}

# Output the London ALB DNS name for reference and troubleshooting.
output "london_alb_dns" {
  description = "DNS name of the London Application Load Balancer"
  value       = aws_lb.london.dns_name
}

# Output the California ALB DNS name for reference and troubleshooting.
output "california_alb_dns" {
  description = "DNS name of the California Application Load Balancer"
  value       = aws_lb.california.dns_name
}