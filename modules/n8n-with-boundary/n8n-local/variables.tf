variable "prefix" {
  type        = string
  description = "Prefix to add to all resources"
  default     = "n8n"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate ARN for HTTPS support"
  default     = null
}

variable "url" {
  type        = string
  description = "URL for n8n (default is LB url), needs a trailing slash if you specify it"
  default     = null
}

variable "desired_count" {
  type        = number
  description = "Desired count of n8n tasks, be careful with this to make it more than 1 as it can cause issues with webhooks not registering properly"
  default     = 1
}

variable "container_image" {
  type        = string
  description = "Container image to use for n8n"
  default     = "n8nio/n8n:1.4.0"
}

variable "fargate_type" {
  type        = string
  description = "Fargate type to use for n8n (either FARGATE or FARGATE_SPOT))"
  default     = "FARGATE_SPOT"
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy for HTTPS listner."
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to deploy n8n into (optional, creates new VPC if not provided)"
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ECS tasks (optional, uses VPC subnets if not provided)"
  default     = []
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnet IDs for ALB (optional, uses VPC public subnets if not provided)"
  default     = []
}

variable "use_private_subnets" {
  type        = bool
  description = "Whether to deploy ECS tasks in private subnets (requires NAT Gateway or VPC endpoints for internet access)"
  default     = false
}

variable "alb_allowed_cidr_blocks" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the ALB (default: allows all traffic)"
  default     = ["0.0.0.0/0"]
}

# New variable for permissions boundary
variable "permissions_boundary_arn" {
  type        = string
  description = "ARN of the permissions boundary policy to attach to IAM roles"
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
