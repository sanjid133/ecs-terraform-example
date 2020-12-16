resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.name}-ecs-cluster"
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "${var.name}-svc"
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task_definition.arn
  desired_count   = var.replica
  launch_type     = "FARGATE"


  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.name
    container_port   = var.container_port
  }

  network_configuration {
    assign_public_ip = false
    security_groups = [
      aws_security_group.egress-all.id,
      aws_security_group.api-ingress.id,
    ]
    subnets = [
      aws_subnet.private.id
    ]
  }
}

resource "aws_cloudwatch_log_group" "app-log" {
  name = "/ecs/${var.name}"
}

resource "aws_ecs_task_definition" "app_task_definition" {
  family                   = "${var.name}-app"
  container_definitions    = data.template_file.app.rendered
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = data.aws_iam_role.ecs_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

data "template_file" "app" {
  template = file("tasks/app.json")
  vars = {
    name       = var.name
    image_name = aws_ecr_repository.app-ecr.repository_url
    image_tag  = var.image_tag
    aws_region = var.region
    port       = var.container_port
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.app-vpc.id

  health_check {
    enabled = true
    path    = "/health"
  }

  depends_on = [aws_alb.alb]
}


resource "aws_alb" "alb" {
  name               = "${var.name}-lb"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public.id,
    aws_subnet.public2.id,
  ]

  security_groups = [
    aws_security_group.allow_http_https.id,
    aws_security_group.egress-all.id,
  ]

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_alb_listener" "lb-http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

output "alb_url" {
  value = "http://${aws_alb.alb.dns_name}"
}

data "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"
}


# The assume_role_policy field works with the following aws_iam_policy_document to allow
# ECS tasks to assume this role we're creating.
resource "aws_iam_role" "app-task-execution-role" {
  name               = "${var.name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs-task-assume-role.json
}

data "aws_iam_policy_document" "ecs-task-assume-role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Normally we'd prefer not to hardcode an ARN in our Terraform, but since this is
# an AWS-managed policy, it's okay.
data "aws_iam_policy" "ecs-task-execution-role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Attach the above policy to the execution role.
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role" {
  role       = aws_iam_role.app-task-execution-role.name
  policy_arn = data.aws_iam_policy.ecs-task-execution-role.arn
}