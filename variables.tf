variable "region" {
  default = "us-east-2"
}

variable "name" {
  default = "hello-world"
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
  default = "jimmysawczuk/sun-api"
}


variable "image_tag" {
  default = "latest"
}

variable "replica" {
  default = 1
}