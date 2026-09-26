variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "github_subject" {
  type        = string
  description = "GitHub OIDC subject permitted to assume the production Terraform role"
}

variable "role_name" {
  type    = string
  default = "histdata-prod-github-terraform-role"
}
