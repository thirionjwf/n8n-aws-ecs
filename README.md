# n8n on AWS ECS (Terraform)

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
    - Replace `profile = "your-profile"` with the name of your configured AWS CLI profile (one that has **Access Key ID** and **Secret Access Key**).
    - Replace `bucket = "<your bucket name>"` with the name of your S3 bucket that will store Terraform state.
    - Verify the backend `region` matches the S3 bucket’s region.
    - (Optional) Set `dynamodb_table = "terraform-locks"` if you use state locking.

3. Edit `terraform.tfvars`:
    - Set `aws_region` to the region where your **VPC/ECS/ALB/EFS** will be deployed.
    - Provide your **existing networking** values:
        - `vpc_id`
        - `subnet_ids` (private/app subnets for ECS tasks)
        - `public_subnet_ids` (public subnets for the ALB)
    - Adjust any other variables as needed (see comments in the example file).

4. Configure AWS credentials & export your profile (must match `backend.hcl` and your intended account):

        aws configure --profile your-profile
        export AWS_PROFILE=your-profile

5. Initialize Terraform using the backend config:

        terraform init -reconfigure -backend-config=backend.hcl

6. Validate, plan, and apply:

        terraform validate
        terraform plan
        terraform apply

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
    export AWS_PROFILE=your-profile

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

            terraform init -reconfigure -backend-config=backend.hcl
