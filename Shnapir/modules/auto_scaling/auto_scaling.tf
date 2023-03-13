variable "vpc_prv_subnet_id" {}
variable "vpc_pub_subnet_id" {}
variable "vpc_id" {}
variable "sg_id" {}

resource "aws_launch_template" "shnapir_launch_template" {
  name_prefix   = "Shnapir-Launch-Template"
  image_id      = "ami-09cd747c78a9add63" # Ubuntu 20.04 ami
  instance_type = "t2.micro"
  key_name      = "Shnapir"
  user_data = base64encode("echo 'Hello, World!' > /tmp/hello.txt")

  network_interfaces {
    device_index               = 0
    associate_public_ip_address = true
    security_groups             = [var.sg_id]
    subnet_id                   = var.vpc_prv_subnet_id
  }
}

resource "aws_autoscaling_group" "shnapir_asg" {
  name = "Shnapir-ASG"
  launch_template {
    id      = aws_launch_template.shnapir_launch_template.id
    version = "$Latest"
  }
vpc_zone_identifier = [var.vpc_prv_subnet_id]

  min_size = 2
  max_size = 4
}

output "asg_id" {
  value = aws_autoscaling_group.shnapir_asg.id
}

# ELB
resource "aws_lb" "shnapir_lb" {
  name        = "shnapir-lb"
  internal    = false
  load_balancer_type = "application"
  security_groups    = [var.sg_id]
  subnets            = [var.vpc_prv_subnet_id, var.vpc_pub_subnet_id]
  tags = {
    Name = "Shnapir_elb"
  }
}

resource "aws_lb_listener" "shnapir_lb_listener" {
  load_balancer_arn = aws_lb.shnapir_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.shnapir_lb_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "shnapir_lb_target_group" {
  name        = "shnapir-target-group"
  port     = "8000"
  protocol = "HTTP"
  vpc_id      = var.vpc_id
  deregistration_delay = 30
  
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 15
    timeout             = 3
    path                = "/"
    matcher             = "200"
  }
}

# ECR
resource "aws_ecr_repository" "shnapir_ecr" {
  name                 = "shnapir-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# ECS
resource "aws_ecs_cluster" "shnapir_ecs" {
  name = "shnapir_ecs"
}

# ecs service creation
resource "aws_ecs_service" "shnapir_ecs_service" {
  name            = "shnapir-ecs-service"
  cluster         = aws_ecs_cluster.shnapir_ecs.id
  task_definition = aws_ecs_task_definition.shnapir_task.arn
  desired_count   = 1
  launch_type     = "EC2"
  load_balancer {
    target_group_arn = aws_lb_target_group.shnapir_lb_target_group.arn
    container_name   = "shnapir_container"
    container_port   = 8000
  }
}


resource "aws_ecs_task_definition" "shnapir_task" {
  family         = "shnapir_task"
  container_definitions = jsonencode(
    [
      {
        name      = "shnapir_container",
        cpu       = 1,
        memory    = 512,
        essential = true,
        image     = "334604350470.dkr.ecr.us-east-1.amazonaws.com/shnapir-ecr",
        # "environment": [],
        portMappings = [
          {
            containerPort = 8000,
            hostPort = 8000,
            protocol = "tcp"
          }
        ]
          
      }
    ]
  )
}