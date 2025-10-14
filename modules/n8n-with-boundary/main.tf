terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Use our local n8n module that creates roles WITH permissions boundary
module "n8n" {
  source = "./n8n-local"

  permissions_boundary_arn = var.permissions_boundary_arn
  
  prefix               = var.prefix
  vpc_id               = var.vpc_id
  subnet_ids           = var.subnet_ids
  public_subnet_ids    = var.public_subnet_ids
  use_private_subnets  = var.use_private_subnets

  container_image      = var.container_image
  desired_count        = var.desired_count
  fargate_type         = var.fargate_type

  alb_allowed_cidr_blocks = var.alb_allowed_cidr_blocks
  certificate_arn         = var.certificate_arn
  ssl_policy              = var.ssl_policy
  url                     = var.url
  tags                    = var.tags

  # Existing Security Groups (managed by admins)
  alb_security_group_id = var.alb_security_group_id
  efs_security_group_id = var.efs_security_group_id
  ecs_security_group_id = var.ecs_security_group_id

  # ECR Repository
  ecr_repository_name = var.ecr_repository_name
}

# No need for null_resource approach since roles are created with permissions boundary natively
