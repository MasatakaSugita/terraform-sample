data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

#最新のリビジョンのタスク定義を取得
data "aws_ecs_task_definition" "main" {
  task_definition = aws_ecs_task_definition.main.family
}


#----------------------------
# ECS_Service
#----------------------------
resource "aws_ecs_service" "main" {
  depends_on = [aws_lb_listener_rule.main]

  name = var.app_name

  launch_type = "FARGATE"
  platform_version = "1.4.0"

  desired_count = 1

  cluster = var.cluster_name

  // CI側との差分を出さないように常に最新のRevisionを参照するようにする
  task_definition = data.aws_ecs_task_definition.main.id

  network_configuration {
    subnets = var.public_subnet_ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name = "nginx"
    container_port = 80
  }
}

#----------------------------
# タスク定義
#----------------------------
resource "aws_ecs_task_definition" "main" {
  family = var.app_name

  cpu = 256
  memory = 512
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  container_definitions = data.template_file.container_definitions.rendered

  volume {
    name = "app-storage"
  }

  task_role_arn      = var.iam_role_task_execution_arn
  execution_role_arn = var.iam_role_task_execution_arn
}

data "template_file" "container_definitions" {
  template = file("./module/ecs_app/container_definitions.json")

  vars = {
    tag = "latest"

    name = var.app_name

    account_id = data.aws_caller_identity.current.account_id
    region     = data.aws_region.current.name
  }
}

#----------------------------
# cloud watch ロググループ作成
#----------------------------
resource "aws_cloudwatch_log_group" "main" {
  name = "/${var.app_name}/ecs"
  retention_in_days = var.retention_in_days
}

#----------------------------
# SG ECS用
#----------------------------
resource "aws_security_group" "ecs" {
  name = "${var.app_name}-ecs"

  vpc_id = var.vpc_id

  egress {
    from_port = 0
    protocol  = "-1"
    to_port   = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol  = "tcp"
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-ecs"
  }
}

#----------------------------
# ターゲットグループ作成
#----------------------------
resource "aws_lb_target_group" "main" {
  name = var.app_name

  vpc_id = var.vpc_id

  port = 80
  target_type = "ip"
  protocol = "HTTP"

  health_check {
    port = 80
    path = "/"
  }
}

resource "aws_lb_listener_rule" "main" {
  listener_arn = var.https_listener_arn

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}