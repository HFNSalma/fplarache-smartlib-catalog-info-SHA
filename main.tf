#Configuration des providers

provider "aws"{
  region = var.aws_region

   # Ajout de tags globaux
  default_tags {
    tags = {
      Env         = "dev"
      Owner       = "HAFIANI_Salma"
      Project     = "smartlib-catalog"
    }
  }
}

#Création du repository ECR
resource "aws_ecr_repository" "app_repo" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"
}

#Création d'un cluster ECS
resource "aws_ecs_cluster" "app_cluster" {
  name = var.ecs.cluster_name
}

# Création de la task définition ECS
resource "aws_ecs_task_definition" "app_task" {
  family               = var.ecs_task_family

  container_definitions = <<DEFINITION
  [
    {
      "name": "fplarache-smartlib-catalog-container-sha",
      "image": "${aws_ecr_repository.app_repo.repository_url}:latest",
      "memory": 512,
      "cpu": 256,
      "essential": true
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
}

#Création du service ECS
resource "aws_ecs_service" "app_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.app_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
   }

   desired_count = 1
}

# Rôle IAM pour ECS
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole_sha"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attachement de la politique IAM pour ECS
resource "aws_iam_role_policy_attachment" "ecs_task_execution_attachment" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

 

