# AWS ECR Repository Setup with Terraform

This Terraform configuration sets up an AWS Elastic Container Registry (ECR) to hold Docker images for deployment to 
Amazon ECS. It includes a lifecycle policy to manage untagged images and provisions the necessary AWS resources to 
build and push a Docker image to the repository.

This setup should be completed before executing the parent directory scripts.

## Prerequisites

Before you begin, ensure you have the following installed on your local machine:

- [Terraform](https://www.terraform.io/downloads.html) (version `~> 1.0`)
- [AWS CLI](https://aws.amazon.com/cli/)
- [Docker](https://www.docker.com/products/docker-desktop)
- AWS credentials configured in your environment (`~/.aws/credentials`)


## Variables

The following variables should be defined in a `terraform.tfvars` file or provided during Terraform plan/apply:

- `aws_region`: The AWS region where the resources will be created (e.g., `us-west-2`).
- `app_name`: The name of the application, which will be used as the ECR repository name.
- `untagged_images`: The number of untagged images to retain in the repository.

Example `terraform.tfvars`:

```hcl
aws_region     = "us-west-2"
app_name       = "my-application"
untagged_images = 10
