variable "name" { type = string }
variable "vpc_id" { type = string }
variable "database_subnet_ids" { type = list(string) }
variable "allowed_security_group_id" { type = string }
variable "instance_class" { type = string }
variable "allocated_storage" { type = number }
variable "multi_az" { type = bool }
variable "deletion_protection" { type = bool }
variable "tags" { type = map(string) }

