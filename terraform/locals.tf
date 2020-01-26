data "aws_caller_identity" "current" {}

output "account_id" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "caller_user" {
  value = "${data.aws_caller_identity.current.user_id}"
}

# CI Cluster Locals

locals {
  project = "neo"
	domain_name = "zaksnotes.com"
  vpc_cidr = "10.20.0.0/16"
  vpc_subnet_private_cidrs = ["10.20.4.0/22", "10.20.8.0/22", "10.20.12.0/22"]
  vpc_subnet_public_cidrs = ["10.20.16.0/22", "10.20.20.0/22", "10.20.24.0/22"]
  aws_region = "us-east-2"
  aws_region_azs = ["us-east-2a", "us-east-2b", "us-east-2c"]
  default_tags = {
    Project = local.project
		Guru = "Zakaria Boualaid"
    Region = "us-east-2"
  }
}
