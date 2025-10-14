variable "permissions_boundary_arn" {
  description = "ARN of the existing permissions boundary policy"
  type        = string
}

# Passthroughs to the upstream module (add more if you need them)
variable "prefix" {
  type    = string
  default = "n8n"
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_ids" {
  type    = list(string)
  default = []
}

variable "public_subnet_ids" {
  type    = list(string)
  default = []
}

variable "use_private_subnets" {
  type    = bool
  default = false
}

variable "container_image" {
  type    = string
  default = "n8nio/n8n:1.4.0"
}

variable "desired_count" {
  type    = number
  default = 1
}

variable "fargate_type" {
  type    = string
  default = "FARGATE_SPOT"
}

variable "alb_allowed_cidr_blocks" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "certificate_arn" {
  type    = string
  default = null
}

variable "ssl_policy" {
  type    = string
  default = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "url" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = null
}

# If upstream role names ever change, you can override them here
variable "execution_role_name" {
  description = "Name of the ECS task execution role created by the upstream module"
  type        = string
  default     = null
}

variable "task_role_name" {
  description = "Name of the ECS task role created by the upstream module"
  type        = string
  default     = null
}

# Existing Security Groups (managed by admins)
variable "alb_security_group_id" {
  type        = string
  description = "ID of existing ALB security group (managed by admins)"
}

variable "efs_security_group_id" {
  type        = string
  description = "ID of existing EFS security group (managed by admins)"
}

variable "ecs_security_group_id" {
  type        = string
  description = "ID of existing ECS security group (managed by admins)"
}

variable "ecr_repository_name" {
  type        = string
  description = "Name of the ECR repository for n8n images"
  default     = "external/n8n"
}
