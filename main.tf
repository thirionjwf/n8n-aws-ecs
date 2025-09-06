module "n8n" {
  source  = "elasticscale/n8n/aws"
  version = ">= 4.0.0"

  # Networking
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  public_subnet_ids   = var.public_subnet_ids
  use_private_subnets = var.use_private_subnets

  # ALB access / TLS (Cloudflare terminates TLS; keep ACM null)
  alb_allowed_cidr_blocks = var.alb_allowed_cidr_blocks
  certificate_arn         = null
  ssl_policy              = var.ssl_policy

  # ECS / app
  container_image = var.container_image
  desired_count   = var.desired_count
  fargate_type    = var.fargate_type

  # Naming & tagging
  prefix = var.prefix
  tags   = var.tags

  # Public URL (null = ALB DNS; if hostname, include trailing slash)
  url = var.url
}

