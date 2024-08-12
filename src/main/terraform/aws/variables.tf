variable "app_name" {
  description = "The name of the application."
  type = string
  default = "hashi-quarkus"
}

variable "aws_region" {
  description = "The AWS region where resources will be created. Default is set to US West (Oregon) region."
  type        = string
  default     = "us-west-2"
}

variable "aws_availability_zone_1" {
  description = "The first Availability Zone within the specified AWS region. Default is set to us-west-2a in the US West (Oregon) region."
  type        = string
  default     = "us-west-2a"
}

variable "aws_availability_zone_2" {
  description = "The second Availability Zone within the specified AWS region. Default is set to us-west-2b in the US West (Oregon) region."
  type        = string
  default     = "us-west-2b"
}

variable "untagged_images" {
  description = "It's a good practice to remove unused docker images - ECR will delete any versions older than untagged_images"
  default = 3
}

variable "ecr_app_name" {
  description = "Name of the application  to be packaged for deployment. This will appear within the ECR  repository and will be used to tag the Docker image."
  type        = string
  default     = "hashicorp.com/hashi-quarkus"
}
