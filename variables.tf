variable "aws_region" {
  default = "eu-north-1"
}

variable "ecr_repository_name" {
 default     = "dev-fplarache-smartlib-catalog-repo-sha"
}

variable "ecs_cluster_name" {
default     = "dev-fplarache-smartlib-catalog-fgcluster-sha"
}

variable "ecs_task_family" {
  default     = "fplarache-smartlib-catalog-td-sha"
}

variable "ecs_service_name" {
  default     = "dev-fplarache-smartlib-catalog-fgservice-sha"
}

variable "subnet_ids" {
  type = list(string)
}
