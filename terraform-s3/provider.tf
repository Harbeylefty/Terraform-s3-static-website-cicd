terraform {
  backend "s3" {
    bucket = "statefilelocking2024"
    dynamodb_table = "state-lock"
    key = "global/s3/terraform.tfstate"
    region = "us-east-1"
    encrypt = true 
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.66.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}