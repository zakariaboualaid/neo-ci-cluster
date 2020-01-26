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
  cluster_name = "${local.project}-eks-${random_pet.this.id}"
	cluster_version = "1.14"

  tags = merge(local.default_tags, {
    "Name" = "${local.project}-ci-cluster"
  })

  subnets = module.vpc.private_subnets 
  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 15
  }

  node_groups = {
    ci_cluster = {
      desired_capacity = 1
      max_capacity     = 2
      min_capacity     = 1

      instance_type = "t3a.xlarge"
      k8s_labels = {
        Environment = "neo"
        GithubOrg   = "zakariaboualaid"
      }
    }
  }

  map_users = [
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Zakaria_Boualaid"
      username = "Zakaria_Boualaid"
      groups   = ["system:masters"]
    }
  ]

}

