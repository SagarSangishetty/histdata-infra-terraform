output "endpoint" { value = aws_db_instance.oracle.address }
output "port" { value = aws_db_instance.oracle.port }
output "db_name" { value = aws_db_instance.oracle.db_name }
output "master_secret_arn" { value = try(aws_db_instance.oracle.master_user_secret[0].secret_arn, null) }
output "application_secret_arn" { value = aws_secretsmanager_secret.application.arn }
output "security_group_id" { value = aws_security_group.oracle.id }
