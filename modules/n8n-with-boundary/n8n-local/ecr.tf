# ECR Repository Resource Policy to allow ECS execution role to pull images
resource "aws_ecr_repository_policy" "n8n_ecr_policy" {
  repository = var.ecr_repository_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSExecutionRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.executionrole.arn
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer", 
          "ecr:BatchGetImage"
        ]
      }
    ]
  })
}
