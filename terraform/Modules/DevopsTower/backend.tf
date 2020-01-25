terraform {
  backend "s3" {
    bucket = "devops-tower-terraform"
    key    = "devops-tower.tfstate"
    region = "us-east-2"
  }
}
