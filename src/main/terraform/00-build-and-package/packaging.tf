
  resource "null_resource" "docker_packaging" {

  provisioner "local-exec" {
    working_dir = "../../../.."
    command = <<EOF
	    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${split("/", aws_ecr_repository.repo.repository_url)[0]}
        docker build -t ${aws_ecr_repository.repo.repository_url} -f src/main/docker/Dockerfile.native -t ${var.app_name}:latest .
        docker push ${aws_ecr_repository.repo.repository_url}
	    EOF
  }

  triggers = {
    "run_at" = timestamp()
  }


  depends_on = [
    aws_ecr_repository.repo
  ]
}