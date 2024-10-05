# create s3 Bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname
}

# Add additional configuarations 

# Define ownership control so that everything in the bucket is owned by bucketowner
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Make bucket public using public access block resource
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# Add acl (access control lists) to make sure that the bucket is ready for the website
# After applying these changes we will see that the bucket is now ready to set up our static website on it.

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.public_access,
  ]

  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"
}

# Upload files to bucket
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"

  acl = "public-read"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"

  acl = "public-read"
}

# Setup website 
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
  depends_on = [aws_s3_bucket_acl.bucket_acl]
}
