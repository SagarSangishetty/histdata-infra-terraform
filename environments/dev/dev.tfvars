aws_region                  = "us-east-1"
project_name                = "histdata"
environment                 = "dev"
availability_zones          = ["us-east-1a", "us-east-1b"]
kubernetes_version          = "1.35"
cluster_public_access_cidrs = 

github_oidc_provider_arn = "arn:aws:iam::935776475838:oidc-provider/token.actions.githubusercontent.com"
github_app_subject       = "repo:SagarSangishetty@143182794/histdata-app@1367058462:ref:refs/heads/main"
github_deploy_subject    = "repo:SagarSangishetty@143182794/histdata-k8s-deployments@1367082451:ref:refs/heads/main"
sso_admin_role_arn       = "arn:aws:iam::935776475838:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AdministratorAccess_2b6037c295c49db8"

domain_name    = "dev.histdata.sagarshetty.online"
hosted_zone_id = "Z04001601UWG9BF9XIIU5"

enable_datasync         = false
datasync_agent_arn      = ""
onprem_nfs_server       = ""
onprem_nfs_subdirectory = "/histdata"
