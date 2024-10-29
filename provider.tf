# terraform setting
terraform {
  required_version = ">= 1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # S3 remote backend configuration
  backend "s3" {
    bucket = "s3-remote-backend-2024"
    key    = "wd102-bootcamp/database-migration.tfstate"
    region = "us-west-2"
    #dynamodb_table = ""   
    encrypt = true
  }
}

# provider
provider "aws" {
  region = "us-west-2"
}

