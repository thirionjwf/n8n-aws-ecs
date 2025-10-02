# Re-expose whatever you need from the upstream module.
# (Add more outputs here if you use them elsewhere.)
output "lb_dns_name" {
  value = module.n8n.lb_dns_name
}

output "lb_zone_id" {
  value = module.n8n.lb_zone_id
}
