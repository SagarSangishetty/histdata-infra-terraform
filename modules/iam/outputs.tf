output "app_irsa_role_arn" { value = aws_iam_role.app.arn }
output "alb_controller_role_arn" { value = aws_iam_role.alb_controller.arn }
output "external_secrets_role_arn" { value = aws_iam_role.external_secrets.arn }
output "github_actions_role_arn" { value = aws_iam_role.github_actions.arn }
output "github_deploy_role_arn" { value = aws_iam_role.github_deploy.arn }
