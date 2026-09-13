variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "github_owner" {
  type    = string
  default = "SagarSangishetty"
}

variable "github_owner_id" {
  type    = string
  default = "143182794"
}

variable "github_repository" {
  type    = string
  default = "histdata-infra-terraform"
}

variable "github_repository_id" {
  type    = string
  default = "1367082211"
}

variable "github_branch" {
  type    = string
  default = "main"
}

variable "role_name" {
  type    = string
  default = "histdata-github-terraform-role"
}
