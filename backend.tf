terraform {
  required_providers {
    aws = ">=3.0.0"
  }
  backend "s3" {
    region  = "us-east-1"
    profile = "default"
    key     = "terraform-state-file"
    bucket  = "<nome-de-um-bucket-já-existente>"
  }
}
