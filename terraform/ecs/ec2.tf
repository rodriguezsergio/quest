resource "aws_launch_configuration" "ecs-launch-config" {
    name_prefix                 = "ecs-lc-"
    image_id                    = "ami-07fde2ae86109a2af" # Amazon Linux AMI 2.0.20210520 x86_64 ECS HVM GP2
    instance_type               = "t3a.small"
    iam_instance_profile        = data.aws_iam_instance_profile.ecsInstanceRole.arn
    security_groups             = [data.aws_security_group.alb_to_backend.id]
    associate_public_ip_address = false
    enable_monitoring           = false
    ebs_optimized               = false

    user_data = <<EOF
#cloud-config

runcmd:
 - echo "ECS_CLUSTER=${aws_ecs_cluster.cluster.arn}" >> /etc/ecs/ecs.config
    EOF

    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_group" "ecs-asg" {
  name                      = "ecs-asg"
  vpc_zone_identifier       = [
                                data.aws_subnet.us-east-1a.id,
                                data.aws_subnet.us-east-1b.id,
                                data.aws_subnet.us-east-1d.id
                              ]
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = false
  termination_policies      = ["default"]
  launch_configuration      = aws_launch_configuration.ecs-launch-config.name
  service_linked_role_arn   = data.aws_iam_role.AWSServiceRoleForAutoScaling.arn

  tag {
    key                 = "Environment"
    value               = "ecs-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "ecs-cpu-scale-up" {
  name                   = "ecs-cpu-scale-up"
  autoscaling_group_name = aws_autoscaling_group.ecs-asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  scaling_adjustment     = 2
}

resource "aws_autoscaling_policy" "ecs-cpu-scale-down" {
  name                   = "ecs-cpu-scale-down"
  autoscaling_group_name = aws_autoscaling_group.ecs-asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  cooldown               = 300
  scaling_adjustment     = -1
}

resource "aws_cloudwatch_metric_alarm" "cpu-spike" {
  alarm_name               = "cpu-spike"
  alarm_description        = "Increase ASG capacity when there is a spike in CPU utilization."
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  evaluation_periods       = "2"
  metric_name              = "CPUUtilization"
  namespace                = "AWS/EC2"
  period                   = "120"
  statistic                = "Average"
  threshold                = "80"
  actions_enabled          = true
  alarm_actions            = [aws_autoscaling_policy.ecs-cpu-scale-up.arn]
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ecs-asg.name
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu-spike-recovered" {
  alarm_name               = "cpu-spike-recovered"
  alarm_description        = "Decrease capacity in the ASG when average CPU utilization falls below a certain threshold."
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  evaluation_periods       = "2"
  metric_name              = "CPUUtilization"
  namespace                = "AWS/EC2"
  period                   = "120"
  statistic                = "Average"
  threshold                = "60"
  actions_enabled          = true
  ok_actions               = [aws_autoscaling_policy.ecs-cpu-scale-down.arn]
  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ecs-asg.name
  }
}
