terraform {
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

// create s3 bucket for state-file 
resource "aws_s3_bucket" "statefile" {
  bucket = "statefilelocking2024"
}

// Enable versioning. Versioning is used to have different versions of your object inside the S3 bucket
// you can always go back to refer to any version you want
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.statefile.id
  versioning_configuration {
    status = "Enabled"
  }
}

// Enable encryption 
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.statefile.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm  = "AES256"
    }
  }
}

// Restrict public access to bucket
resource "aws_s3_bucket_public_access_block" "acl" {
  bucket = aws_s3_bucket.statefile.id

  block_public_acls = true
  block_public_policy = true 
}

// create dynamodb table for statefile lock
resource "aws_dynamodb_table" "statelock" {
  name = "state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}