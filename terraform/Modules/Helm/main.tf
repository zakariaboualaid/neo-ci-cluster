provider "aws" {
  region = "us-east-2"
}

provider "helm" {
  install_tiller  = true
  service_account = kubernetes_service_account.tiller.metadata.0.name
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
    name = kubernetes_service_account.tiller.metadata.0.name
    namespace = "kube-system"
  }
}
