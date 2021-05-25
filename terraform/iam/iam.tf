provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ECS_task_execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/instance_IAM_role.html
resource "aws_iam_instance_profile" "ecsInstanceRole" {
  name = "ecsInstanceRole"
  role = aws_iam_role.ecsInstanceRole.name
}

resource "aws_iam_role" "ecsInstanceRole" {
  name = "ecsInstanceRole"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "ecsInstanceRole" {
  role       = aws_iam_role.ecsInstanceRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_service_linked_role" "AWSServiceRoleForECS" {
  aws_service_name = "ecs.amazonaws.com"
  description = "Role to enable Amazon ECS to manage your cluster."
}

resource "aws_iam_service_linked_role" "AWSServiceRoleForASG" {
  aws_service_name = "autoscaling.amazonaws.com"
}
