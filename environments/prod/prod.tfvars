aws_region         = "us-east-1"
project_name       = "histdata"
environment        = "prod"
vpc_cidr           = "10.50.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
kubernetes_version = "1.35"

node_instance_types = ["m6i.large"]
node_desired_size   = 3
node_min_size       = 3
node_max_size       = 6

oracle_instance_class      = "db.t3.medium"
oracle_allocated_storage   = 100
oracle_multi_az            = true
oracle_deletion_protection = true

github_oidc_provider_arn = "arn:aws:iam::708553018735:oidc-provider/token.actions.githubusercontent.com"

github_app_subject = "repo:SagarSangishetty@143182794/histdata-app@1367058462:environment:prod"

github_deploy_subject = "repo:SagarSangishetty@143182794/histdata-k8s-deployments@1367082451:environment:prod"

sso_admin_role_arn = "arn:aws:iam::708553018735:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_e518b4d7cae964cc"

domain_name    = "prod.histdata.sagarshetty.online"
hosted_zone_id = "Z0922803263UXHNF1GCZQ"

enable_datasync         = false
datasync_agent_arn      = ""
onprem_nfs_server       = ""
onprem_nfs_subdirectory = "/histdata"
