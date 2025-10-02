# Use hardcoded permissions boundary ARN to avoid data source hanging issues
module "n8n" {
  # Use the wrapper module instead of the registry source
  source = "./modules/n8n-with-boundary"

  # --- Use hardcoded boundary ARN ---
  permissions_boundary_arn = "arn:aws:iam::314429811214:policy/permission-boundary"

  # Networking
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  public_subnet_ids   = var.public_subnet_ids
  use_private_subnets = var.use_private_subnets

  # ALB access / TLS
  alb_allowed_cidr_blocks = var.alb_allowed_cidr_blocks
  certificate_arn         = var.acm_certificate_arn
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

  # Existing Security Groups (managed by admins)
  alb_security_group_id = var.alb_security_group_id
  efs_security_group_id = var.efs_security_group_id
  ecs_security_group_id = var.ecs_security_group_id

  # ECR Repository
  ecr_repository_name = var.ecr_repository_name
}
