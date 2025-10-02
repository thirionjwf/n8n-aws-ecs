output "lb_dns_name" {
  description = "Load balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "lb_zone_id" {
  description = "Zone ID of the ALB for Route 53 alias records"
  value       = aws_lb.main.zone_id
}
