data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.10"
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "8.1.0"
  cluster_name = "${local.project}-eks"

  tags = merge(local.default_tags, {
    "Name" = "${local.project}-eks"
  })

  subnets = module.vpc.private_subnets 
  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 2
    }
  ]

  workers_group_defaults = {
    target_group_arns = concat([
      module.alb.target_group_arns[0]
    ])
    subnets = module.vpc.private_subnets
  }

  worker_groups_launch_template = [
    {
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

  write_kubeconfig = "true"

  map_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Zakaria_Boualaid"
      username = "Zakaria_Boualaid"
      groups   = ["system:masters"]
    }
  ]

}

#resource "helm_release" "nginx_ingress" {
  #name          = "nginx-ingress"
  #chart         = "stable/nginx-ingress"
  #version       = "1.24.1"
  #namespace     = "kube-system"
  #force_update  = true

  #values = [
    #file("../helm/nginx_controller.yaml")
  #]
#}
