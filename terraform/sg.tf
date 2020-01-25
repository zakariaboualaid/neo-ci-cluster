module "security_group_alb" {
  source = "terraform-aws-modules/security-group/aws"
  version = "3.4.0"

  name = "${local.project}-sg-alb"
  description = "Public ALB Security Group"
  vpc_id = module.vpc.vpc_id
  use_name_prefix = false

  egress_with_cidr_blocks = [
    {
      rule = "all-tcp"
      cidr_blocks = local.vpc_cidr
      description = "ALL TCP (Internal VPC)"
    }
  ]
  ingress_with_cidr_blocks = [
    {
      rule = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "TCP 80 (Universal Access)"
    }
  ]

  tags = merge(local.default_tags, {
    "Name" = "${local.project}-sg-alb"
  })
}

module "security_group_eks_worker_from_alb" {
  source = "terraform-aws-modules/security-group/aws"
  version = "3.4.0"

  name = "${local.project}-sg-eks-worker-from-alb"
  description = "EKS Worker from ALB SG"
  vpc_id = module.vpc.vpc_id
  use_name_prefix = false

  ingress_with_source_security_group_id = [
    {
      rule = "all-tcp"
      source_security_group_id = module.security_group_alb.this_security_group_id
      description = "ALL TCP (ALB Access)"
    }
  ]

  tags = merge(local.default_tags, {
    "Name" = "${local.project}-sg-eks-worker-from-alb"
  })
}
