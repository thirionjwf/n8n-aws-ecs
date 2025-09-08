terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# 1) Call upstream module as-is
module "n8n" {
  source  = "elasticscale/n8n/aws"
  version = ">= 4.0.0"

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
}

# 2) Derive role names based on upstream convention
locals {
  default_execution_role = "${var.prefix}-executionrole"
  default_task_role      = "${var.prefix}-taskrole"

  execution_role_name = coalesce(var.execution_role_name, local.default_execution_role)
  task_role_name      = coalesce(var.task_role_name,      local.default_task_role)

  # Optional profile flag (empty string if not set)
  profile_flag = var.aws_profile != null ? " --profile ${var.aws_profile}" : ""
}

# 3) Apply permissions boundary using AWS CLI after roles exist
# Use upstream output (lb_dns_name) to force a reliable dependency
resource "null_resource" "set_permissions_boundary_execution" {
  triggers = {
    role_name = local.execution_role_name
    boundary  = var.permissions_boundary_arn
    mod_hash  = module.n8n.lb_dns_name
  }

  provisioner "local-exec" {
    command = "aws iam put-role-permissions-boundary --role-name ${self.triggers.role_name} --permissions-boundary ${self.triggers.boundary}${local.profile_flag}"
  }

  # Cleanup on destroy so delete works smoothly
  provisioner "local-exec" {
    when    = destroy
    command = "aws iam delete-role-permissions-boundary --role-name ${self.triggers.role_name}${local.profile_flag} || true"
  }
}

resource "null_resource" "set_permissions_boundary_task" {
  triggers = {
    role_name = local.task_role_name
    boundary  = var.permissions_boundary_arn
    mod_hash  = module.n8n.lb_dns_name
  }

  provisioner "local-exec" {
    command = "aws iam put-role-permissions-boundary --role-name ${self.triggers.role_name} --permissions-boundary ${self.triggers.boundary}${local.profile_flag}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "aws iam delete-role-permissions-boundary --role-name ${self.triggers.role_name}${local.profile_flag} || true"
  }
}
