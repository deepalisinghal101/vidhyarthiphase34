output "zone_id" {
  description = "The ID of the Route 53 private hosted zone"
  value       = aws_route53_zone.private.zone_id
}

output "zone_name" {
  description = "The domain name of the private hosted zone"
  value       = aws_route53_zone.private.name
}
