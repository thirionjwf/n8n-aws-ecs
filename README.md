# n8n on AWS ECS with Terraform

Provision **n8n** on **AWS ECS Fargate** using the [`elasticscale/terraform-aws-n8n`](https://github.com/elasticscale/terraform-aws-n8n) module.

This branch is designed for environments where **Terraform manages all resources**, including security groups and IAM roles. No permissions boundary is required.

---

## Features

- Deploys n8n on AWS ECS Fargate with an Application Load Balancer and EFS storage
- Manages all required security groups directly in Terraform
- Supports both DockerHub and AWS ECR as container registries
- Creates all necessary IAM roles and policies for ECS and ECR access

---

## Prerequisites

- An existing VPC with:
  - At least 3 private subnets (for ECS tasks)
  - At least 3 public subnets (for the ALB)
  - Subnets distributed across multiple availability zones
- S3 bucket for Terraform state (and optional DynamoDB table for state locking)
- AWS CLI profile with permissions to create all required resources

---

## Quick Start

1. Copy the example files into place:
    - `providers.tf.example` → `providers.tf`
    - `backend.hcl.example` → `backend.hcl`
    - `terraform.tfvars.example` → `terraform.tfvars`

2. Edit `backend.hcl`:
    - Set your AWS CLI profile name
    - Set your S3 bucket name
    - Set the region and (optionally) DynamoDB table

3. Edit `terraform.tfvars`:
    - Set `aws_region` for deployment
    - Provide your VPC and subnet IDs
    - Optionally set ECR repository or DockerHub image

4. Configure AWS credentials:
    ```sh
    aws configure --profile your-profile
    export AWS_PROFILE=your-profile
    ```

5. Initialize and deploy:
    ```sh
    terraform init -reconfigure -backend-config=backend.hcl
    terraform validate
    terraform plan
    terraform apply
    ```

---

## Security Groups

Terraform will create and manage the following security groups:

| Security Group | Purpose | Inbound Rules | Outbound Rules |
|---------------|---------|---------------|----------------|
| n8n-alb       | Application Load Balancer | TCP 80, 443 from 0.0.0.0/0 | All traffic |
| n8n-sg        | ECS Tasks                 | TCP 5678 from n8n-alb SG    | All traffic |
| n8n-efs       | Elastic File System       | TCP 2049, 2999 from n8n-sg  | All traffic |

---

## Container Registry

- **DockerHub**: Default image is `n8nio/n8n:latest`
- **ECR**: To use a private ECR image, push your image and set the repository name in `terraform.tfvars`

Example ECR push:
```sh
docker pull n8nio/n8n:latest
docker tag n8nio/n8n:latest <account-id>.dkr.ecr.<region>.amazonaws.com/external/n8n:latest
aws ecr get-login-password --region <region> | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/external/n8n:latest
```

---

## Cleanup

To destroy all resources:
```sh
terraform destroy
```

---

## Troubleshooting

- **VPC/Subnet Issues**: Ensure all subnet IDs belong to the specified VPC and region.
- **Backend Errors**: Double-check S3 bucket, region, and profile in `backend.hcl`.
- **ECR Authentication**: Ensure IAM roles have correct ECR permissions.

---

## Attribution

Based on [`elasticscale/terraform-aws-n8n`](https://github.com/elasticscale/terraform-aws-n8n).
