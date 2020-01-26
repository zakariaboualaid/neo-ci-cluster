provider "aws" {
  region = "us-east-2"
}

provisioner "local-exec" {
	# Provision kubernetes loadbalancer service
	command = "kubectl --kubeconfig=${module.eks.kubeconfig} apply -f ../kubectl"
}

resource "random_pet" "this" {
  length = 2
}

data "aws_route53_zone" "this" {
  name = local.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 2.0"

  domain_name = trimsuffix(data.aws_route53_zone.this.name, ".")
  zone_id     = data.aws_route53_zone.this.id
}
