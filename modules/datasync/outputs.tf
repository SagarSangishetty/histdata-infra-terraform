output "task_arn" { value = var.enabled ? aws_datasync_task.this[0].arn : null }

