resource "tls_private_key" "rearc" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "self_signed_cert" {
  key_algorithm   = "ECDSA"
  private_key_pem = tls_private_key.rearc.private_key_pem

  subject {
    common_name  = "rearc.io"
    organization = "rearc"
  }

  validity_period_hours = 36500

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_iam_server_certificate" "self_signed_cert" {
  name_prefix      = "self_signed_cert"
  certificate_body = tls_self_signed_cert.self_signed_cert.cert_pem
  private_key      = tls_private_key.rearc.private_key_pem
}

resource "aws_lb" "lb" {
  name               = "lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_http.id]
  subnets            = aws_subnet.public.*.id

  enable_deletion_protection = false

  tags = {
    Environment = "prod"
  }
}

resource "aws_lb_target_group" "app" {
  name     = "app-lb-tg"
  port     = var.port
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    interval = 10
    healthy_threshold = 4
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener" "http-80" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group" "app-https" {
  name     = "app-https-lb-tg"
  port     = var.port
  protocol = "HTTPS"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"

  health_check {
    interval = 10
    healthy_threshold = 4
    unhealthy_threshold = 2
  }

}

resource "aws_lb_listener" "https-443" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_iam_server_certificate.self_signed_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
