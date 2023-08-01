#-------------------------------------------------------------------------------------------------------------------------------
# Terraform Plugin - AWS cloud provider
#-------------------------------------------------------------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
#Configure s3 remote backend for state file
terraform {
  backend "s3" {
    bucket         = "s3-backend-state-bucket-270"
    key            = "level2.tfstate"
    region         = "us-east-1"
    dynamodb_table = "state-lock"
  }
}
