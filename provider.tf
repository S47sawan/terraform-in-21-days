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
  region = "eu-west-2"
}

#Configure s3 remote backend for state file
terraform {
  backend "s3" {
    bucket = "terraform-remote-state-smihah"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}


