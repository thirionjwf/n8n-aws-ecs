output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.n8n.lb_dns_name
}

output "alb_url" {
  description = "Full URL of the Application Load Balancer"
  value       = "https://${module.n8n.lb_dns_name}/"
}
