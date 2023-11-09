terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.12.1"
    }
  }

  backend "s3" {
    bucket         = "terraformstaterakesh"  # Add the opening quote here
    key            = "terraform.tfstate"      # Replace with your desired state file name
    region         = "us-east-1"              # Replace with the appropriate region
    encrypt        = true
    dynamodb_table = "tf-state-lock-dynamo"   # Optional: Use a DynamoDB table for locking
  }
}

resource "aws_s3_bucket" "new_bucket" {
  bucket = "demo-github-action-tf-medium"

  object_lock_enabled = false

  tags = {
    Environment = "Prod"
  }
}

