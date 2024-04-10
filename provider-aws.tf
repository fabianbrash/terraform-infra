terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0" # Specify your desired version
    }
  }
}


provider "aws" {
  region                  = "us-west-2" # Change to us-west-1 if preferred
  access_key              = "<>"
  secret_key              = "<>"
}
