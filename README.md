# n8n on AWS ECS with Terraform (Corporate Environment)

Deploy **n8n** on **AWS ECS Fargate** in a corporate environment with IAM permissions boundaries and admin-managed security groups.

This is a specialized fork of the [elasticscale/terraform-aws-n8n](https://github.com/elasticscale/terraform-aws-n8n) module, modified for corporate environments where:

- **Security Groups** are managed by the Cloud Security team (not Terraform)
- **IAM Roles** require a permissions boundary policy
- **Private ECR** or DockerHub can be used as container registry

---

## Corporate Environment Requirements

### Prerequisites

1. **VPC and Subnets**: You need an existing VPC with:
   - 3 private subnets (for ECS tasks)
   - 3 public subnets (for ALB)
   - Subnets distributed across different availability zones
   - Public subnets attached to Internet Gateway
   - Private subnets routed through NAT Gateway(s) with Elastic IPs

2. **Security Groups**: The following security groups must be pre-created by your Cloud Security team:

   | Security Group | Purpose | Inbound Rules | Outbound Rules |
   |---------------|---------|---------------|----------------|
   | `n8n-alb` | Application Load Balancer | TCP 80, 443 from 0.0.0.0/0 | All traffic |
   | `n8n-sg` | ECS Tasks | TCP 5678 from n8n-alb SG | All traffic |
   | `n8n-efs` | Elastic File System | TCP 2049, 2999 from n8n-sg | All traffic |

3. **IAM Permissions Boundary**: A policy that allows most actions but restricts IAM user/role creation:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "AllowEverythingExceptIAMUserRoleCreation",
         "Effect": "Allow",
         "Action": "*",
         "Resource": "*"
       },
       {
         "Sid": "DenyIAMUserAndRoleCreation",
         "Effect": "Deny",
         "Action": [
           "iam:CreateRole",
           "iam:CreateUser"
         ],
         "Resource": "*"
       }
     ]
   }
   ```

4. **Route 53 Public Hosted Zone & ACM Certificate**:
   - Create a public hosted zone in Route 53 for your domain (e.g., `example.com`).
   - Update your domain registrar to use the name servers provided by the Route 53 hosted zone.
   - In AWS Certificate Manager (ACM), request a new certificate for your desired subdomain (e.g., `example.com`).
   - When prompted, add the DNS validation records to your Route 53 hosted zone.
   - Wait until the ACM certificate status is **Issued** before running `terraform apply`.

### Container Registry Options

#### Option 1: Private ECR (Recommended for Corporate)

1. Create ECR repository (e.g., `external/n8n`)
2. Upload n8n image to ECR:

   ```bash
   # Pull official n8n image
   docker pull n8nio/n8n:latest
   
   # Tag for your ECR
   docker tag n8nio/n8n:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/external/n8n:latest
   
   # Login to ECR
   aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
   
   # Push to ECR
   docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/external/n8n:latest
   ```

#### Option 2: DockerHub (if allowed)

Use the default DockerHub image: `n8nio/n8n:latest`

---

## Quick Start

1. **Copy example files**:

   ```bash
   cp providers.tf.example providers.tf
   cp backend.hcl.example backend.hcl  
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Configure backend** (`backend.hcl`):
   - Set your AWS profile name
   - Set S3 bucket for state storage
   - Set DynamoDB table for state locking (optional)

3. **Configure deployment** (`terraform.tfvars`):
   ```hcl
   # AWS Configuration
   aws_region = "us-west-2"
   aws_profile = "your-corporate-profile"
   
   # Networking (existing VPC)
   vpc_id = "vpc-xxxxxxxxx"
   subnet_ids = ["subnet-aaaaa", "subnet-bbbbb", "subnet-ccccc"]
   public_subnet_ids = ["subnet-11111", "subnet-22222", "subnet-33333"]
   
   # Security Groups (pre-created by security team)
   alb_security_group_id = "sg-xxxxxxxxx"  # n8n-alb
   ecs_security_group_id = "sg-yyyyyyyyy"  # n8n-sg
   efs_security_group_id = "sg-zzzzzzzzz"  # n8n-efs
   
   # IAM Permissions Boundary
   permissions_boundary_arn = "arn:aws:iam::<your-account-id>:policy/permission-boundary"
   
   # ACM Certificate & Route 53
   acm_certificate_arn = "arn:aws:acm:<your-region>:<your-account-id>:certificate/YOUR_CERTIFICATE_ID"
   route53_zone_id = "<your-zone-id>"
   route53_record_name = "n8n.example.com"
   
   # Container Registry
   ecr_repository_name = "external/n8n"  # For ECR
   # container_image = "n8nio/n8n:latest"  # For DockerHub
   ```

4. **Deploy**:

   ```bash
   # Configure AWS credentials
   export AWS_PROFILE=your-corporate-profile
   
   # Initialize Terraform
   terraform init -reconfigure -backend-config=backend.hcl
   
   # Deploy
   terraform validate
   terraform plan
   terraform apply
   ```

> **Important:** Set the `url` variable in `terraform.tfvars` to the public DNS name (e.g. `https://n8n.example.com/`) that users and webhooks will access. This must match your Route 53 Alias record and SSL certificate. Do NOT use the raw ALB DNS name.

---

## Architecture

This deployment creates the following AWS resources:

### Core Infrastructure
- **ECS Cluster**: Fargate cluster for running n8n containers
- **ECS Service**: Manages n8n task instances (recommended: 1 task)
- **Application Load Balancer**: Routes traffic to ECS tasks
- **Elastic File System**: Persistent storage for n8n data

### IAM Resources (with Permissions Boundary)
- **Task Role**: IAM role for n8n application with permissions boundary
- **Execution Role**: IAM role for ECS task execution with ECR access and permissions boundary
- **ECR Repository Policy**: Grants ECS execution role access to pull images

### Security
- **Security Groups**: Uses existing security groups (managed by security team)
- **IAM Permissions Boundary**: Applied to all created IAM roles
- **Private Subnets**: ECS tasks run in private subnets for enhanced security

---

## Configuration Variables

### Required Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `"<your-region>"` |
| `aws_profile` | AWS CLI profile name | `"<your-profile>"` |
| `vpc_id` | Existing VPC ID | `"vpc-xxxxxxxxx"` |
| `subnet_ids` | Private subnet IDs for ECS tasks | `["subnet-aaa", "subnet-bbb"]` |
| `public_subnet_ids` | Public subnet IDs for ALB | `["subnet-111", "subnet-222"]` |
| `alb_security_group_id` | Pre-created ALB security group | `"sg-xxxxxxxxx"` |
| `ecs_security_group_id` | Pre-created ECS security group | `"sg-yyyyyyyyy"` |
| `efs_security_group_id` | Pre-created EFS security group | `"sg-zzzzzzzzz"` |
| `permissions_boundary_arn` | IAM permissions boundary policy ARN | `"arn:aws:iam::<your-account-id>:policy/YOUR_PERMISSION_BOUNDARY_POLICY_NAME"` |
| `acm_certificate_arn` | ACM certificate ARN for HTTPS | `"arn:aws:acm:<your-region>:<your-account-id>:certificate/YOUR_CERTIFICATE_ID"` |
| `route53_zone_id` | Route 53 hosted zone ID | `"<your-zone-id>"` |
| `route53_record_name` | DNS record name | `"n8n.example.com"` |

### Container Registry Variables (Choose One)

| Variable | Description | Example |
|----------|-------------|---------|
| `ecr_repository_name` | ECR repository name (for private ECR) | `"external/n8n"` |
| `container_image` | Full Docker image path (for DockerHub) | `"n8nio/n8n:latest"` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `environment_name` | Environment name prefix | `"n8n"` |
| `desired_count` | Number of ECS tasks | `1` |
| `cpu` | ECS task CPU units | `512` |
| `memory` | ECS task memory (MB) | `1024` |
| `capacity_provider` | ECS capacity provider | `"FARGATE_SPOT"` |

---

## Troubleshooting

### Common Issues

#### Security Group Access
- **Error**: ECS tasks cannot reach EFS
- **Solution**: Verify EFS security group allows TCP 2049 and 2999 from ECS security group

#### ECR Authentication
- **Error**: Image pull failures from ECR
- **Solution**: Ensure ECS execution role has ECR permissions and repository policy allows access

#### Permissions Boundary
- **Error**: IAM role creation fails
- **Solution**: Verify permissions boundary policy exists and is attached during role creation

#### VPC/Subnet Issues
- **Error**: No matching VPC or subnets found
- **Solution**: Confirm region, profile, and subnet IDs belong to specified VPC

### Validation Commands

```bash
# Verify VPC and subnets
aws ec2 describe-vpcs --vpc-ids <vpc-id> --region <your-region>
aws ec2 describe-subnets --subnet-ids <subnet-id> --region <your-region>

# Check security groups
aws ec2 describe-security-groups --group-ids <sg-id> --region <your-region>

# Verify IAM permissions boundary
aws iam get-policy --policy-arn arn:aws:iam::<your-account-id>:policy/<boundary-name>

# Test ECR access
aws ecr describe-repositories --repository-names <your-repo-name> --region <your-region>
```

---

## Important Notes

### Corporate Compliance
- **Permissions Boundary**: All IAM roles created by this module automatically include the specified permissions boundary
- **Security Groups**: This module does NOT create or modify security groups - they must be pre-created
- **ECR Access**: Repository-level policies are created to grant specific access to ECS execution roles

### Networking Requirements
- **Private Subnets**: ECS tasks run in private subnets for security
- **NAT Gateway**: Required for ECS tasks to access internet (ECR, package updates)
- **Load Balancer**: Deployed in public subnets to receive internet traffic

### Security Considerations
- **Least Privilege**: IAM roles include only necessary permissions
- **Network Isolation**: Tasks isolated in private subnets
- **Encryption**: EFS supports encryption at rest and in transit

---

## Cleanup

To destroy the deployment:

```bash
terraform destroy
```

**Note**: This will destroy all Terraform-managed resources but will NOT delete the pre-existing security groups or VPC infrastructure.

---

## Support

For issues specific to the permissions boundary implementation, please open an issue on the [permissions-boundary branch](https://github.com/thirionjwf/n8n-aws-ecs/tree/permissions-boundary).

For general n8n deployment questions, refer to the upstream [elasticscale/terraform-aws-n8n](https://github.com/elasticscale/terraform-aws-n8n) repository.

Provision **n8n** on **AWS ECS Fargate** using the `elasticscale/n8n/aws` Terraform module.

This project **assumes an existing VPC** — you will provide `vpc_id`, `subnet_ids`, and `public_subnet_ids` that already exist in your AWS account.

---

## Quick Start

1. Copy the example files into place (required):
    - `providers.tf.example` → `providers.tf`
    - `backend.hcl.example` → `backend.hcl`
    - `terraform.tfvars.example` → `terraform.tfvars`

   Example:
    
        cp providers.tf.example providers.tf
        cp backend.hcl.example backend.hcl
        cp terraform.tfvars.example terraform.tfvars

2. Edit `backend.hcl` and replace placeholders:
    - Replace `profile = "<your-profile>"` with the name of your configured AWS CLI profile (one that has **Access Key ID** and **Secret Access Key**).
    - Replace `bucket = "<your-terraform-state-aws-s3-bucket>"` with the name of your S3 bucket that will store Terraform state.
    - Verify the backend `region` matches the S3 bucket’s region.
    - (Optional) Set `dynamodb_table = "<your-terraform-dynamodb-locks-table>"` if you use state locking.

3. Edit `terraform.tfvars`:
    - Set `aws_region` to the region where your **VPC/ECS/ALB/EFS** will be deployed.
    - Provide your **existing networking** values:
        - `vpc_id`
        - `subnet_ids` (private/app subnets for ECS tasks)
        - `public_subnet_ids` (public subnets for the ALB)
    - Adjust any other variables as needed (see comments in the example file).

4. Configure AWS credentials & export your profile (must match `backend.hcl` and your intended account):

        aws configure --profile <your-profile>
        export AWS_PROFILE=<your-profile>

5. Initialize Terraform using the backend config:

        terraform init -reconfigure -backend-config=backend.hcl

6. Validate, plan, and apply:

        terraform validate
        terraform plan
        terraform apply

> **Important:** Set the `url` variable in `terraform.tfvars` to the public DNS name (e.g. `https://n8n.example.com/`) that users and webhooks will access. This must match your Route 53 Alias record and SSL certificate. Do NOT use the raw ALB DNS name.

---

## Important Notes

- **Assumes Existing VPC:** This stack does **not** create a VPC. All `subnet_ids` must belong to the provided `vpc_id`.
- **Replace Placeholders:**
  - `your-profile` → your actual AWS CLI profile name.
  - `"<your bucket name>"` → the S3 bucket that stores Terraform state.
- **Check Regions:**
  - `backend.hcl: region` → S3 **backend** (state) region.
  - `terraform.tfvars: aws_region` → **deployment** region for ECS/ALB/EFS/VPC.
  These can differ; ensure each is correct for its purpose.
- **Credentials:** Ensure your chosen profile has valid **Access Key ID** and **Secret Access Key**, and permissions to read/create the required resources.

---

## Common Commands

    # Use a specific profile for this shell
    export AWS_PROFILE=<your-profile>

    # Reconfigure backend if backend.hcl changes
    terraform init -reconfigure -backend-config=backend.hcl

    # Standard workflow
    terraform validate
    terraform plan
    terraform apply

    # Tear down the stack
    terraform destroy

---

## Troubleshooting

- `no matching EC2 VPC found`
    - Confirm `aws_region` in `terraform.tfvars` matches the VPC’s region.
    - Verify `AWS_PROFILE` points to the correct AWS account.
    - Ensure all `subnet_ids` belong to the specified `vpc_id` in that account/region. For a quick check:

            AWS_PROFILE=your-profile aws ec2 describe-vpcs --vpc-ids vpc-xxxxxxxx --region <aws_region>

- Backend init errors
    - Double-check `backend.hcl` values (`bucket`, `region`, `profile`, optional `dynamodb_table`) and re-run:

- terraform init -reconfigure -backend-config=backend.hcl
