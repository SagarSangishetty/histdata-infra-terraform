terraform {
  backend "s3" {
    bucket       = "histdata-terraform-state-708553018735-us-east-1"
    key          = "histdata/bootstrap/dns/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
