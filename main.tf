terraform {
  backend "s3" {
    bucket = "hw-terraform-bucket"
    key = "helloworld"
    region = "us-east-2"
    profile = "tfuser"
  }
}

provider "aws" {
  region = "${var.region}"
  profile = "tfuser"
}

