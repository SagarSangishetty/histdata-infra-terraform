locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "DevOps"
  }
}

data "aws_caller_identity" "current" {}

module "network" {
  source             = "../../modules/network"
  name               = local.name
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  tags               = local.common_tags
}

module "storage" {
  source      = "../../modules/storage"
  bucket_name = "${local.name}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"
  tags        = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"
  name   = "histdata-app"
  tags   = local.common_tags
}

module "eks" {
  source                      = "../../modules/eks"
  name                        = "${local.name}-eks"
  kubernetes_version          = var.kubernetes_version
  private_subnet_ids          = module.network.private_subnet_ids
  cluster_public_access_cidrs = var.cluster_public_access_cidrs
  node_instance_types         = var.node_instance_types
  node_desired_size           = var.node_desired_size
  node_min_size               = var.node_min_size
  node_max_size               = var.node_max_size
  tags                        = local.common_tags
}

module "rds" {
  source                    = "../../modules/rds"
  name                      = local.name
  vpc_id                    = module.network.vpc_id
  database_subnet_ids       = module.network.database_subnet_ids
  allowed_security_group_id = module.eks.node_security_group_id
  instance_class            = var.oracle_instance_class
  allocated_storage         = var.oracle_allocated_storage
  multi_az                  = var.oracle_multi_az
  deletion_protection       = var.oracle_deletion_protection
  tags                      = local.common_tags
}

module "iam" {
  source                   = "../../modules/iam"
  name                     = local.name
  oidc_provider_arn        = module.eks.oidc_provider_arn
  oidc_issuer_url          = module.eks.oidc_issuer_url
  data_bucket_arn          = module.storage.bucket_arn
  application_secret_arn   = module.rds.application_secret_arn
  ecr_repository_arn       = module.ecr.repository_arn
  eks_cluster_arn          = module.eks.cluster_arn
  github_oidc_provider_arn = var.github_oidc_provider_arn
  github_app_subject       = var.github_app_subject
  github_deploy_subject    = var.github_deploy_subject
  tags                     = local.common_tags

}

resource "aws_eks_access_entry" "github_deploy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.iam.github_deploy_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "github_deploy" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.iam.github_deploy_role_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope { type = "cluster" }
  depends_on = [aws_eks_access_entry.github_deploy]
}

module "dns" {
  source         = "../../modules/dns"
  enabled        = var.domain_name != "" && var.hosted_zone_id != ""
  domain_name    = var.domain_name
  hosted_zone_id = var.hosted_zone_id
  tags           = local.common_tags
}

module "datasync" {
  source              = "../../modules/datasync"
  enabled             = var.enable_datasync
  name                = local.name
  agent_arn           = var.datasync_agent_arn
  nfs_server_hostname = var.onprem_nfs_server
  nfs_subdirectory    = var.onprem_nfs_subdirectory
  s3_bucket_arn       = module.storage.bucket_arn
  schedule_expression = var.datasync_schedule_expression
  tags                = local.common_tags
}

resource "aws_eks_access_entry" "sso_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = var.sso_admin_role_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "sso_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.sso_admin.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
