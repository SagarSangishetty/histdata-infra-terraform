variable "name" { type = string }
variable "kubernetes_version" {
  type    = string
  default = null
}
variable "private_subnet_ids" { type = list(string) }
variable "cluster_public_access_cidrs" { type = list(string) }
variable "node_instance_types" { type = list(string) }
variable "node_desired_size" { type = number }
variable "node_min_size" { type = number }
variable "node_max_size" { type = number }
variable "tags" { type = map(string) }
