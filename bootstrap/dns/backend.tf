terraform {
  backend "s3" {
    bucket       = "histdata-terraform-state-935776475838-us-east-1"
    key          = "histdata/bootstrap/dns/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
    encrypt      = true
  }
}