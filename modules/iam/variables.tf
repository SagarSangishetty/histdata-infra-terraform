variable "name" { type = string }
variable "oidc_provider_arn" { type = string }
variable "oidc_issuer_url" { type = string }
variable "data_bucket_arn" { type = string }
variable "application_secret_arn" { type = string }
variable "ecr_repository_arn" { type = string }
variable "eks_cluster_arn" { type = string }
variable "tags" { type = map(string) }
variable "github_oidc_provider_arn" {
  type        = string
  description = "ARN of the shared GitHub Actions OIDC provider"
}
variable "github_app_subject" {
  type        = string
  description = "OIDC subject for the application repository"
}
variable "github_deploy_subject" {
  type        = string
  description = "OIDC subject for the Kubernetes deployment repository"
}
variable "sso_admin_role_arn" {
  description = "IAM Identity Center role allowed to administer the EKS cluster"
  type        = string
}