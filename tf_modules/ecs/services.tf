resource "aws_ecs_task_definition" "nginx-td" {
  family                   = "nginx"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  container_definitions = jsonencode([{
    name      = "nginx"
    image     = "nginx:latest"
    essential = true
    portMappings = [
      {
        containerPort = 80
        hostPort      = 80
        protocol      = "tcp"
      }
    ]
  }])
}

resource "aws_lb" "nginx-nlb" {
  name               = "nginx-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = jsondecode(var.subnets)
}

resource "aws_lb_target_group" "nginx_tg" {
  name        = "nginx-lb-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "ip"

}


resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx-nlb.arn
  port              = 80
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}



resource "aws_ecs_service" "nginx_service" {
  name            = "nginx"
  cluster         = aws_ecs_cluster.dan_cluster.name
  task_definition = aws_ecs_task_definition.nginx-td.arn
  desired_count   = 1
  launch_type     = "EC2"
  network_configuration {
    subnets          = jsondecode(var.subnets)
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.nginx_tg.arn
    container_name   = "nginx"
    container_port   = 80
  }
}
