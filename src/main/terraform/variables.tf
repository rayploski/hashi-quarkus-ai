variable "app_name" {
  type = string
  default = "hashi-quarkus"
  description = "The name of the application."
}

variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "The AWS region where resources will be created. Default is set to US West (Oregon) region."
}

variable "aws_availability_zone_1" {
  type        = string
  default     = "us-west-2a"
  description = "The first Availability Zone within the specified AWS region. Default is set to us-west-2a in the US West (Oregon) region."
}

variable "aws_availability_zone_2" {
  type        = string
  default     = "us-west-2b"
  description = "The second Availability Zone within the specified AWS region. Default is set to us-west-2b in the US West (Oregon) region."
}
