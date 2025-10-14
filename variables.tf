# Provider helpers
variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "permissions_boundary_arn" {
  type        = string
  description = "ARN of the existing IAM permissions boundary policy"
}

# Networking
variable "vpc_id" {
  type        = string
  description = "Existing VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets for ECS tasks (usually private if use_private_subnets = true)"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnets for ALB"
}

variable "use_private_subnets" {
  type        = bool
  description = "Run tasks in private subnets"
  default     = true
}

# ALB / TLS
variable "alb_allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to reach ALB (layer-3)"
  default     = ["0.0.0.0/0"]
}

variable "ssl_policy" {
  type        = string
  description = "SSL policy name for HTTPS listener (used if certificate_arn set)"
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for HTTPS listener on ALB. Must be in the same region as the ALB."
  default     = null
}

# ECS / app
variable "container_image" {
  type        = string
  description = "n8n container image"
  default     = "n8nio/n8n:1.40.0"
}

variable "desired_count" {
  type        = number
  description = "ECS desired task count"
  default     = 1
}

variable "fargate_type" {
  type        = string
  description = "FARGATE or FARGATE_SPOT"
  default     = "FARGATE_SPOT"
}

# Naming & tagging
variable "prefix" {
  type        = string
  description = "Name prefix for resources"
  default     = "n8n"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources"
  default     = {}
}

# URL
variable "url" {
  type        = string
  description = "Public URL (must end with '/' if set); null uses ALB DNS"
  default     = null
}

# AWS Profile
variable "aws_profile" {
  type        = string
  description = "AWS CLI profile name (optional)"
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

variable "route53_zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID for santam.ltd."
  default     = null
}

variable "route53_record_name" {
  type        = string
  description = "DNS name for the n8n service (e.g. n8n.santam.ltd)"
  default     = null
}
