resource "aws_ecs_cluster" "dan_cluster" {
  name = var.cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

data "http" "my_ip" {
  url = "https://checkip.amazonaws.com/"
}

resource "aws_security_group" "ecs_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ecs-sg"
  }

}

data "aws_ami" "latest_ecs_image" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "ecs_key" {
  key_name   = "ecs_key"
  public_key = file(var.key_path)

}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "ecs"
  image_id      = data.aws_ami.latest_ecs_image.id
  instance_type = "t3.small"
  key_name      = aws_key_pair.ecs_key.key_name
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ecs_sg.id]
  }
  iam_instance_profile {
    name = var.ec2_role_name
  }

  user_data = base64encode(<<EOF
#!/bin/bash
echo "ECS_CLUSTER=${aws_ecs_cluster.dan_cluster.name}" >> /etc/ecs/ecs.config
runcmd:
  - systemctl stop ecs
  - sleep 20
  - systemctl start ecs
EOF
  )
  tags = {
    Name = "ecs-lt"
  }
}


resource "aws_autoscaling_group" "ecs_asg" {
  name             = "ecs-asg"
  desired_capacity = 2
  max_size         = 4
  min_size         = 2
  force_delete     = true

  vpc_zone_identifier = jsondecode(var.subnets)
  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 0
    }
    triggers = ["tag"]
  }
  tag {
    key                 = "Name"
    value               = "ecs-asg"
    propagate_at_launch = false
  }
}

resource "aws_ecs_capacity_provider" "ecs_cp" {
  name = "ec2_cp"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
    managed_draining       = "ENABLED"
  }
  tags = {
    "Name" = "ecs_cp"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cp" {
  cluster_name       = aws_ecs_cluster.dan_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_cp.name, "FARGATE"]
}
