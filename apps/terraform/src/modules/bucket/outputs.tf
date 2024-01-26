output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.hosting.website_endpoint
}


output "bucket_regional_domain_name" {
  value = aws_s3_bucket.app_bucket.bucket_regional_domain_name
}


output "bucket_id" {
  value = aws_s3_bucket.app_bucket.id
}


output "bucket_website_arn" {
  value = aws_s3_bucket.app_bucket.arn
}
