resource "aws_ecr_repository" "app-ecr" {
  name = "${var.name}-repo"
}