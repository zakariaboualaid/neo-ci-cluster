provider "aws" {
  region = "us-east-2"
}

#provider "helm" {
  #kubernetes {
    #config_path = concat([module.eks.config_output_path, module.eks.kubeconfig_name])
  #}
#}
