variable "name" { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_issuer_url" { type = string }
variable "data_bucket_arn" { type = string }
variable "application_secret_arn" { type = string }
variable "ecr_repository_arn" { type = string }
variable "github_repository" {
  type        = string
  description = "GitHub repository in owner/name format"
}
variable "github_deploy_repository" {
  type        = string
  description = "Deployment repository in owner/name format"
}
variable "eks_cluster_arn" { type = string }
variable "tags" { type = map(string) }
