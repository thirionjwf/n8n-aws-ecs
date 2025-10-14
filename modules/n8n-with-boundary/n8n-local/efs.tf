# Use existing EFS security group (managed by admins)
data "aws_security_group" "efs" {
  id = var.efs_security_group_id
}

resource "aws_efs_file_system" "main" {
  creation_token = "${var.prefix}-efs"

  tags = var.tags
}

resource "aws_efs_mount_target" "mount" {
  for_each = zipmap(
    local.azs,
    var.use_private_subnets ? (
      length(var.subnet_ids) > 0 ? var.subnet_ids : (
        var.vpc_id != null ? data.aws_subnets.existing_private[0].ids : module.vpc[0].private_subnets
      )
    ) : local.ecs_subnets
  )
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = each.value
  security_groups = [data.aws_security_group.efs.id]
}

resource "aws_efs_access_point" "access" {
  file_system_id = aws_efs_file_system.main.id
  root_directory {
    path = "/n8n"
    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = "777"
    }
  }

  tags = var.tags
}
