# Provider helpers
variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-west-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile to use (or set AWS_PROFILE env var)"
  default     = null
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform remote state (backend). Note: not used directly in backend block."
}

variable "region" {
  type        = string
  description = "AWS region for provider and resources."
}

# --- NEW ---
variable "permissions_boundary_policy_name" {
  type        = string
  description = "Name of the existing IAM policy used as a permissions boundary"
  default     = "permission-boundary"
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
