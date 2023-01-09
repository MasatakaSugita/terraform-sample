#----------------------------
# ALB
#----------------------------
resource "aws_lb" "main" {
  load_balancer_type = "application"
  name               = var.app_name

  security_groups = [aws_security_group.main.id]
  subnets         = var.public_subnet_ids
}

resource "aws_lb_listener" "http" {
  port     = 80
  protocol = "HTTP"

  load_balancer_arn = aws_lb.main.arn

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

#----------------------------
# SG
#----------------------------
resource "aws_security_group" "main" {
  name        = "${var.app_name}-alb"
  description = "${var.app_name} alb"

  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    protocol  = "tcp"
    to_port   = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-alb"
  }
}

#----------------------------
# Route53 Aレコードを追加
#----------------------------
data "aws_route53_zone" "main" {
  name         = var.zone
  private_zone = false
}

resource "aws_route53_record" "main" {
  type = "A"

  name    = var.domain
  zone_id = data.aws_route53_zone.main.id

  alias {
    name    = aws_lb.main.dns_name
    zone_id = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}