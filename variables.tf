variable "region" {
  default = "us-east-2"
}

variable "name" {
  default = "hello-world"
}
variable "environment" {
  default = "production"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "image" {
  default = "jimmysawczuk/sun-api:latest"
}

variable "replica" {
  default = 1
}