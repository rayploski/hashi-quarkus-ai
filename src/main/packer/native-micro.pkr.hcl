# Define variables
variable "repository" {
  type        = string
  default     = "hashicorp.com/hashi-quarkus"
  description = "The Docker repository where the image will be stored"
}

variable "tag" {
  type        = string
  default     = "latest"
  description = "The tag for the Docker image"
}

variable "source" {
  type        = string
  default     = "target/hashi-quarkus-1.0.0-SNAPSHOT-runner"
  description = "The source path on the host machine"
}

packer {
  required_plugins {
    docker = {
      version = ">= 0.0.7"
      source  = "github.com/hashicorp/docker"
    }
  }
}

# Define the source configuration using the Docker plugin
source "docker" "quarkus" {
  # Base image to use
  image  = "quay.io/quarkus/quarkus-micro-image:2.0"
  # Commit the changes made during provisioning
  commit = true
}

build {
  name    = "hashi-quarkus"
  sources = ["source.docker.quarkus"]
  description = "Simple Quarkus application for use with the HashiCorp technology stack."

  # Provisioner to run shell commands inside the Docker container
  provisioner "shell" {
    inline = [
      # Create the /work directory
      "mkdir -p /work",
      # Set appropriate permissions for the /work directory
      "chmod 775 /work"
    ]
  }

  # Provisioner to copy files from the host machine to the Docker container
  provisioner "file" {
    # Path to the source files on the host machine
    source      = var.source
    # Destination path in the Docker container
    destination = "/work/application"
  }

  # Provisioner to run shell commands inside the Docker container
  provisioner "shell" {
    inline = [
      # Set appropriate permissions for the application file
      "chmod 775 /work/application"
    ]
  }

  # Post-processor to tag the final Docker image
  post-processor "docker-tag" {
    # Specify the repository and tag for the Docker image
    repository = var.repository
    tag        = [var.tag]
  }
}
