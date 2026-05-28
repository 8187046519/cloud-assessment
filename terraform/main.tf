terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28.0"
    }
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


resource "aws_ecs_cluster" "main" {
  name = "cloud-app-cluster"
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/cloud-app"
  retention_in_days = 7

  lifecycle {
    prevent_destroy = false
    ignore_changes  = all
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "cloud-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn = "arn:aws:iam::992382534186:role/ECS_Task_role"

  container_definitions = jsonencode([
    {
      name  = "cloud-app"
      image = "992382534186.dkr.ecr.ap-south-1.amazonaws.com/cloud-app:latest"

      essential = true

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"

      options = {
        awslogs-group         = "/ecs/cloud-app"
        awslogs-region        = "ap-south-1"
        awslogs-stream-prefix = "ecs"
      }
    }
    }
  ])
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-security-group"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "app" {
  name            = "cloud-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }

    load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "cloud-app"
    container_port   = 5000
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "alb-security-group"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_alb" {
  name               = "cloud-app-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg.id]
  subnets          = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "app_tg" {
  name        = "cloud-app-target-group"
  port        = 5000
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    port = "5000"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}