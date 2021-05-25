resource "aws_security_group" "alb_http" {
  name        = "alb_http"
  description = "Accept HTTP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_to_backend" {
  name        = "alb_to_backend"
  description = "Allows LB traffic to reach private subnet instances."
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_http.id]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}