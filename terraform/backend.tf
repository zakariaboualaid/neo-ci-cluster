terraform {
  backend "s3" {
    bucket = "neo-ci-cluster-terraform-${random_pet.this.id}"
    key    = "neo-ci-cluster.tfstate-${random_pet.this.id}"
    region = "us-east-2"
  }
}
