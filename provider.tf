terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # We will use the latest v5 provider
      version = "~> 5.0"
    }
  }
}

# This configures the AWS provider to point to LocalStack
provider "aws" {
  region = "us-east-1"
  
  # These settings are needed for LocalStack
  skip_credentials_validation  = true
  skip_metadata_api_check      = true
  skip_requesting_account_id   = true

  # --- THIS IS THE V5 SYNTAX ---
  # We must define endpoints for each service individually
  endpoints {
    s3             = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    iam            = "http://localhost:4566"
    ec2            = "http://localhost:4566" # Make sure EC2 is here
    cloudformation = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
  }
}