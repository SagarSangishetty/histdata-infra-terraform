variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "histdata"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.40.0.0/16"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "cluster_public_access_cidrs" {
  type        = list(string)
  description = "Trusted administrator public IPs in CIDR form; never leave open to the internet"
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "Pin a currently supported EKS version after checking the target region"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "oracle_instance_class" {
  type    = string
  default = "db.t3.small"
}

variable "oracle_allocated_storage" {
  type    = number
  default = 20
}

variable "oracle_multi_az" {
  type    = bool
  default = false
}

variable "oracle_deletion_protection" {
  type    = bool
  default = false
}

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

variable "domain_name" {
  type        = string
  default     = ""
  description = "Application hostname, for example histdata.example.com"
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "Route 53 hosted-zone ID; keep empty if DNS is managed elsewhere"
}

variable "enable_datasync" {
  type    = bool
  default = false
}

variable "datasync_agent_arn" {
  type    = string
  default = ""
}

variable "onprem_nfs_server" {
  type    = string
  default = ""
}

variable "onprem_nfs_subdirectory" {
  type    = string
  default = "/histdata"
}

variable "datasync_schedule_expression" {
  type        = string
  default     = "cron(0 18 * * ? *)"
  description = "Daily UTC DataSync schedule; adjust to the trading-team delivery window"
}

variable "sso_admin_role_arn" {
  description = "IAM Identity Center role granted EKS administrator access"
  type        = string
}