# Create an AWS Container Registry to hold the packaged build for access by ECS

resource "aws_ecr_repository" "repo" {
  name = var.ecr_app_name
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

# Policy to remove older versions of untagged_images
resource "aws_ecr_lifecycle_policy" "default_policy" {
  repository = aws_ecr_repository.repo.name

  policy = <<EOF
	{
	    "rules": [
	        {
	            "rulePriority": 1,
	            "description": "Keep only the last ${var.untagged_images} untagged images.",
	            "selection": {
	                "tagStatus": "untagged",
	                "countType": "imageCountMoreThan",
	                "countNumber": ${var.untagged_images}
	            },
	            "action": {
	                "type": "expire"
	            }
	        }
	    ]
	}
	EOF
}




