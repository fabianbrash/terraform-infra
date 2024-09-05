# Specify the required Terraform version and configure the backend
terraform {
  required_version = ">= 1.0.0"  # Specify the minimum required Terraform version

  # Required providers
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.1.0"
    }
  }

  # Optional: Configure the backend (e.g., S3, local, etc.)
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "path/to/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

# Configure the AWS provider
provider "aws" {
  region = var.aws_region

  # Optional: If you want to specify a specific profile from your AWS credentials file
  # profile = "your-aws-profile"
}

# Random provider for generating random names
provider "random" {
  # No specific configuration required
}

# Define input variables for AWS region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-west-2" # Update this to your desired AWS region
}

# Optional: Define input variables for AWS profile
# Uncomment if you want to use a specific AWS profile
# variable "aws_profile" {
#   description = "The AWS profile to use from your credentials file"
#   default     = "default" # Change this to the profile name you want to use
# }
