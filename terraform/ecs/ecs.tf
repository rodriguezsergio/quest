provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "app" {
  name = var.repo_name
}

resource "aws_ecs_cluster" "cluster" {
  name = "cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                = "app"
  container_definitions = templatefile("${path.module}/container_definition.tpl", { port = var.port, image_path = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.repo_name}:${var.git_hash}" })
  network_mode          = "awsvpc"
  execution_role_arn = data.aws_iam_role.ecs_task_execution.arn
}

resource "aws_ecs_service" "app" {
  name            = "app"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1

  network_configuration {
    subnets         = [
                        data.aws_subnet.us-east-1a.id,
                        data.aws_subnet.us-east-1b.id,
                        data.aws_subnet.us-east-1d.id
                      ]
    security_groups = [data.aws_security_group.alb_to_backend.id]
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.app.arn
    container_name   = "app"
    container_port   = var.port
  }
}
