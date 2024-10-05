# Output website endpoint to be able to access the website without going into the AWS console
output "website_endpoint" {
  value = aws_s3_bucket.mybucket.website_endpoint
}