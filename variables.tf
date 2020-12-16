variable "region" {
  default = "us-east-2"
}

variable "name" {
  default = "fh-devops-challenge"
}

variable "container_port" {
  default = 9292
}

variable "environment" {
  default = "production"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "image_name" {
  default = ""
}

variable "image_tag" {
  default = "latest"
}

variable "replica" {
  default = 1
}

variable "availability_zones" {
  type = list(string)
  default = [
    "us-east-2a",
    "us-east-2b",
    "us-east-2c",
  ]
}