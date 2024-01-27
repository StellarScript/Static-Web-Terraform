terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}



resource "aws_s3_bucket" "app_bucket" {
  bucket        = var.name
  force_destroy = true
  tags = {
    Name = "app_bucket"
  }
}


resource "aws_s3_bucket_public_access_block" "client-public" {
  bucket = aws_s3_bucket.app_bucket.id
}


resource "aws_s3_bucket_website_configuration" "hosting" {
  bucket = aws_s3_bucket.app_bucket.id

  index_document {
    suffix = "index.html"
  }
}


resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "web-application-app_bucket"
  description                       = ""
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.app_bucket.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "PublicReadGetObject",
          "Effect" : "Allow",
          "Principal" : "*",
          "Action" : "s3:GetObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.app_bucket.id}/*"
        }
      ]
    }
  )
}
