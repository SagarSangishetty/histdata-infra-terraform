provider "aws" {
  region = var.aws_region

  allowed_account_ids = [
    "708553018735"
  ]

  default_tags {
    tags = {
      Project     = "histdata"
      Environment = "prod"
      ManagedBy   = "Terraform"
      Scope       = "Bootstrap"
    }
  }
}
