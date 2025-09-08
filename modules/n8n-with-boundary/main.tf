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

# 2) Role names based on upstream convention (override via vars if needed)
locals {
  default_execution_role = "${var.prefix}-executionrole"
  default_task_role      = "${var.prefix}-taskrole"

  execution_role_name = coalesce(var.execution_role_name, local.default_execution_role)
  task_role_name      = coalesce(var.task_role_name,      local.default_task_role)
}

# 3) Apply permissions boundary using AWS CLI after roles exist
#    Use PowerShell so it runs on Windows; add dependency on upstream module.
resource "null_resource" "set_permissions_boundary_execution" {
  triggers = {
    role_name    = local.execution_role_name
    boundary     = var.permissions_boundary_arn
    mod_hash     = module.n8n.lb_dns_name
    # Make profile available to destroy-time provisioner via self.triggers.*
    profile_flag = var.aws_profile != null ? " --profile ${var.aws_profile}" : ""
  }

  # Create: put boundary
  provisioner "local-exec" {
    command = <<-EOT
      powershell -NoProfile -Command "aws iam put-role-permissions-boundary --role-name ${self.triggers.role_name} --permissions-boundary ${self.triggers.boundary}${self.triggers.profile_flag}"
    EOT
  }

  # Destroy: remove boundary (ignore error if already gone)
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      powershell -NoProfile -Command "& { aws iam delete-role-permissions-boundary --role-name ${self.triggers.role_name}${self.triggers.profile_flag}; if ($LASTEXITCODE -ne 0) { Write-Host 'ignore failure'; exit 0 } }"
    EOT
  }

  depends_on = [module.n8n]
}

resource "null_resource" "set_permissions_boundary_task" {
  triggers = {
    role_name    = local.task_role_name
    boundary     = var.permissions_boundary_arn
    mod_hash     = module.n8n.lb_dns_name
    profile_flag = var.aws_profile != null ? " --profile ${var.aws_profile}" : ""
  }

  # Create: put boundary
  provisioner "local-exec" {
    command = <<-EOT
      powershell -NoProfile -Command "aws iam put-role-permissions-boundary --role-name ${self.triggers.role_name} --permissions-boundary ${self.triggers.boundary}${self.triggers.profile_flag}"
    EOT
  }

  # Destroy: remove boundary (ignore error if already gone)
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      powershell -NoProfile -Command "& { aws iam delete-role-permissions-boundary --role-name ${self.triggers.role_name}${self.triggers.profile_flag}; if ($LASTEXITCODE -ne 0) { Write-Host 'ignore failure'; exit 0 } }"
    EOT
  }

  depends_on = [module.n8n]
}
