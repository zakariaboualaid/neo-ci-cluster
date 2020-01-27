provider "aws" {
  region = "us-east-2"
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

provider "helm" {
  install_tiller  = true
  service_account = ""
  namespace = "kube-system"
}

resource "kubernetes_service_account" "tiller" {
  metadata {
    name = "tiller"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "tiller_cluster_role" {
  metadata {
    name = "tiller"

  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "cluster-admin"
  }

  subject {
    kind = "ServiceAccount"
    name = "default"
    namespace = "kube-system"
  }

  subject {
    kind = "ServiceAccount"
    name = kubernetes_service_account.tiller.metadata.0.name
    namespace = "kube-system"
  }
		
}


