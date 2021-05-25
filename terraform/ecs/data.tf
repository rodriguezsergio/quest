data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_iam_role" "ecs_task_execution" {
  name = "ecs_task_execution"
}

data "aws_iam_instance_profile" "ecsInstanceRole" {
  name = "ecsInstanceRole"
}

data "aws_iam_role" "AWSServiceRoleForAutoScaling" {
  name = "AWSServiceRoleForAutoScaling"
}

data "aws_lb_target_group" "app" {
  name     = "app-lb-tg"
}

data "aws_security_group" "alb_to_backend" {
  name = "alb_to_backend"
  vpc_id = data.aws_vpc.main.id
}

data "aws_subnet" "us-east-1a" {
  vpc_id = data.aws_vpc.main.id
  availability_zone = "us-east-1a"

  tags = {
    Type = "private"
  }
}

data "aws_subnet" "us-east-1b" {
  vpc_id = data.aws_vpc.main.id
  availability_zone = "us-east-1b"

  tags = {
    Type = "private"
  }
}

data "aws_subnet" "us-east-1d" {
  vpc_id = data.aws_vpc.main.id
  availability_zone = "us-east-1d"

  tags = {
    Type = "private"
  }
}

data "aws_vpc" "main" {
  cidr_block = "172.30.0.0/16"
}
