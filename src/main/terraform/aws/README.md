# Terraform for Quarkus Apps on AWS Fargate

## Overview

This Terraform configuration deploys an AWS infrastructure to run a containerized Quarkus application that uses AWS Fargate, with an Application Load Balancer (ALB), ECS service, and other associated AWS resources. The setup includes creating a default VPC, subnets, security groups, IAM roles, a container registry (ECR), and a CloudWatch log group.

## Prerequisites

Ensure you have the following before deploying the Terraform configuration:

- AWS CLI configured with appropriate credentials
- Terraform installed on your local machine
- Docker installed and running on your local machine for building and pushing container images
- An AWS account with necessary permissions to create resources such as VPCs, subnets, security groups, ECS clusters, IAM roles, S3 buckets, and ECR repositories

## Variables

The configuration relies on the following variables:

- `app_name`: Name of the application. Used as a prefix for resource naming.
- `aws_availability_zone_1`: The first AWS availability zone to use.
- `aws_availability_zone_2`: The second AWS availability zone to use.
- `aws_region`: AWS region where the resources will be created.
- `ecr_app_name`: Name of the ECR repository.
- `untagged_images`: Number of untagged images to retain in the ECR repository.

## Resources Created

### VPC and Subnets

- **Default VPC**: A default VPC is created if not already present.
- **Default Subnets**: Two default subnets are created in the specified availability zones.

### Security Groups

- **ALB Security Group**: Allows HTTP traffic (port 80) from all sources and allows outbound traffic to all destinations.
- **Fargate Security Group**: Allows HTTP traffic from the ALB on port 8080 and allows outbound traffic to all destinations.

### IAM Roles

- **Fargate Execution Role**: An IAM role with policies to allow the ECS service to interact with Amazon ECR and CloudWatch.
- **Fargate S3 Role**: An IAM role with policies to allow access to S3 resources.

### Load Balancer and Target Group

- **Application Load Balancer (ALB)**: Distributes incoming traffic to the ECS service.
- **Target Group**: The ALB forwards requests to the ECS tasks based on this target group.

### ECS Cluster, Task Definition, and Service

- **ECS Cluster**: A cluster to run the Fargate service.
- **ECS Task Definition**: Defines the container specifications, including resource requirements, image to be used, and log configuration.
- **ECS Service**: Manages the ECS tasks, ensuring the desired number of tasks are running and are accessible through the ALB.

### CloudWatch Logs

- **CloudWatch Log Group**: Stores logs from the Quarkus backend container.

### S3 Bucket

- **S3 Bucket**: Stores user data with versioning enabled.

### Elastic Container Registry (ECR)

- **ECR Repository**: Stores Docker images for the application.
- **ECR Lifecycle Policy**: Removes older untagged images to optimize storage usage.

## Deployment

1. Clone the repository containing this Terraform configuration.
2. Initialize the Terraform configuration:

   ```bash
   terraform init
   
3. Review the Terraform plan:

   ```bash
   terraform plan
   
4. Apply the Terraform configuration to create the resources:

   ```bash
   terraform apply

Confirm the prompt by typing 'yes'.

## Notes 

- Ensure the necessary IAM policies are attached to the AWS user or role executing this Terraform script
- The ALB access logs section is commented out but can be enabled by specifying an S3 bucket to store the logs.
- The configuration uses default VPC and subnets; if you need a custom VPC setup, modify the VPC and subnet resources accordingly.
