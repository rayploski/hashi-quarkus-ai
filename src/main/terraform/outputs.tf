
output "app_url" {
  description = "The URL to reach your deployed application."
  value = aws_lb.alb-for-fargate.dns_name
}

output "aws_repo" {
  description = "The AWS ECR repository holding the container image of the application."
  value = split("/", aws_ecr_repository.repo.repository_url)[0]
}