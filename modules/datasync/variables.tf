variable "enabled" { type = bool }
variable "name" { type = string }
variable "agent_arn" { type = string }
variable "nfs_server_hostname" { type = string }
variable "nfs_subdirectory" { type = string }
variable "s3_bucket_arn" { type = string }
variable "schedule_expression" { type = string }
variable "tags" { type = map(string) }
