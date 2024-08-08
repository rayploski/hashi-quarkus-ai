terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.61.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.aws_region
}

resource "aws_default_vpc" "default-vpc"{
  tags = {
    Name="Default Vpc"
  }
}

resource "aws_default_subnet" "default-subnet-1" {
  availability_zone = var.aws_availability_zone_1
  tags = {
    Name = "Default subnet for AZ1"
  }
}

resource "aws_default_subnet" "default-subnet-2" {
  availability_zone = var.aws_availability_zone_2

  tags = {
    Name = "Default subnet for AZ2"
  }
}

# Create a security group for the ALB
resource "aws_security_group" "alb-sg" {
  description = "sg for the ALB"
  name        = "alb-sg"
  vpc_id      = aws_default_vpc.default-vpc.id

  ingress {
    description     = "Allow HTTP from all"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description     = "Allow to all"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# Create a security group for the Fargate Service
resource "aws_security_group" "fargate-sg" {
  description = "sg for the Fargate Service"
  name        = "fargate-sg"
  vpc_id      = aws_default_vpc.default-vpc.id

  ingress {
    description     = "Allow HTTP from ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb-sg.id]
  }

  egress {
    description     = "Allow to all"
    from_port       = 0
    to_port         = 0
    protocol        = -1
    cidr_blocks     = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

# IAM policy document for ECS assume role
data "aws_iam_policy_document" "ecs-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IAM role for Fargate execution
resource "aws_iam_role" "fargate-execution" {
  name = "fargate-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json

  inline_policy {
    name   = "execution_role"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": "*"
        }
      ]
    })
  }
}

# IAM role for Fargate with S3 permissions
resource "aws_iam_role" "fargate-s3-role" {
  name = "fargate-s3-role"

  assume_role_policy = data.aws_iam_policy_document.ecs-assume-role-policy.json

  inline_policy {
    name   = "role_for_s3"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:*",
          ],
          "Resource": "*"
        }
      ]
    })
  }
}

# Create an Application Load Balancer
resource "aws_lb" "alb-for-fargate" {
  name               = "alb-for-quarkus"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_default_subnet.default-subnet-1.id, aws_default_subnet.default-subnet-2.id]
}

# Create a target group for the ALB
resource "aws_lb_target_group" "alb-tg-fargate" {
  port         = 80
  protocol     = "HTTP"
  target_type  = "ip"
  vpc_id       = aws_default_vpc.default-vpc.id

  lifecycle {
    create_before_destroy = true
  }
}

# Create a target group for JVM Lambda
resource "aws_lb_target_group" "alb-tg-jvmLambda" {
  target_type = "lambda"
  name        = "jvmLambdaTg"
}

# Create a target group for Native Lambda
resource "aws_lb_target_group" "alb-tg-nativeLambda" {
  target_type = "lambda"
  name        = "nativeLambdaTg"
}

# Create a listener for the ALB
resource "aws_lb_listener" "fargate-listener" {
  load_balancer_arn = aws_lb.alb-for-fargate.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg-fargate.arn
  }
}

# Listener rule to direct traffic to JVM Lambda
resource "aws_lb_listener_rule" "direct-to-jvm" {
  listener_arn = aws_lb_listener.fargate-listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg-jvmLambda.arn
  }
  condition {
    path_pattern {
      values = ["/jvm/lambda*"]
    }
  }
}

# Listener rule to direct traffic to Native Lambda
resource "aws_lb_listener_rule" "direct-to-native" {
  listener_arn = aws_lb_listener.fargate-listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg-nativeLambda.arn
  }
  condition {
    path_pattern {
      values = ["/native/lambda*"]
    }
  }
}

# CloudWatch log group for Quarkus backend
resource "aws_cloudwatch_log_group" "quarkus-backend-logs" {
  name = "quarkus-backend"
}

# S3 bucket for storing user data
resource "aws_s3_bucket" "users-bucket" {
  bucket = "hashi-users"
}

# Enable versioning on the S3 bucket
resource "aws_s3_bucket_versioning" "users-bucket-versioning" {
  bucket = aws_s3_bucket.users-bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_ecs_task_definition" "quarkus-task" {
  cpu = "512"
  memory = "2048"
  family = "service"
  requires_compatibilities =["FARGATE"]
  execution_role_arn = aws_iam_role.fargate-execution.arn
  task_role_arn = aws_iam_role.fargate-s3-role.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture = "X86_64"
  }
  network_mode = "awsvpc"
  container_definitions = jsonencode([
    {
      name = "hashi-quarkus"
      image = "YOUR_ECR_URL_HERE"
      cpu = 512
      memory = 2048
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort = 8080
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "hashi-quarkus"
          awslogs-region = var.aws_region
          awslogs-stream-prefix = "quarkus-container"
        }
      }
      /*
     logConfiguration =  [
       {
         logDriver = "awslogs"
         options = {
           awslogs-group = "hashi-quarkus"
           awslogs-region = var.aws_region
           awslogs-stream-prefix = "quarkus-container"
         }
       }
     ]

       */
    }
  ])
}

resource "aws_ecs_cluster" "quarkus-cluster" {
  name = "quarkus-cluster"
}
resource "aws_ecs_service" "quarkus-service" {
  name            = "quarkus-service"
  cluster         = aws_ecs_cluster.quarkus-cluster.id
  task_definition = aws_ecs_task_definition.quarkus-task.arn
  desired_count   = 1
  depends_on      = [aws_iam_role.fargate-s3-role,aws_iam_role.fargate-execution,aws_lb_target_group.alb-tg-fargate]
  launch_type = "FARGATE"
  network_configuration {
    subnets =[aws_default_subnet.default-subnet-1.id,aws_default_subnet.default-subnet-2.id]
    assign_public_ip = true
    security_groups =[aws_security_group.fargate-sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.alb-tg-fargate.arn
    container_name   = "hashi-quarkus"
    container_port   = 8080
  }


}