module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "8.1.0"
  cluster_name = "${local.project}-eks"

  tags = merge(local.default_tags, {
    "Name" = "${local.project}-eks"
  })

  subnets = module.vpc.private_subnets 
  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    target_group_arns = concat([
      module.alb.target_group_arns[0]
    ])
    subnets = module.vpc.private_subnets
  }

  worker_groups_launch_template = [
    {
      asg_max_size = 1
      asg_min_size = 1
      asg_desired_capacity = 1
      on_demand_base_capacity = 0
      on_demand_percentage_above_base_capacity = 0
      root_volume_size = 10
    }
  ]

  worker_additional_security_group_ids = [
    module.security_group_eks_worker_from_alb.this_security_group_id
  ]

  workers_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  ]

  write_aws_auth_config = "false"
  write_kubeconfig = "false"

  map_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Zakaria_Boualaid"
      username = "Zakaria_Boualaid"
      groups   = ["system:masters"]
    }
  ]

}

resource "helm_release" "nginx_ingress" {
  name          = "nginx-ingress"
  chart         = "stable/nginx-ingress"
  version       = "1.24.1"
  namespace     = "kube-system"
  force_update  = true

  values = [
    file("../helm/nginx_controller.yaml")
  ]
}
