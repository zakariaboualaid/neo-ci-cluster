terraform {
  backend "s3" {
    bucket = "neo-ci-cluster-terraform"
    key    = "neo-ci-cluster.tfstate"
    region = "us-east-2"
  }
}
