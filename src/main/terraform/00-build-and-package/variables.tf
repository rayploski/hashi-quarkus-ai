variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "The AWS region where resources will be created. Default is set to US West (Oregon) region."
}

variable "untagged_images" {
  default = 3
  description = "It's a good practice to remove unused docker images - ECR will delete any versions older than untagged_images"
}

variable "app_name" {
  type        = string
  description = "Name of the application  to be packaged for deployment. This will appear within the ECR  repository and will be used to tag the Docker image."
  default     = "hashicorp.com/hashi-quarkus"
}
