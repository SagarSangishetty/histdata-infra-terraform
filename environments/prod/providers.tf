provider "aws" {
  region = var.aws_region

  allowed_account_ids = [
    "708553018735"
  ]

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
