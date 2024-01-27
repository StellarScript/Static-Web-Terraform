terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


module "app_bucket" {
  source = "./modules/bucket"
  name   = var.bucket_name
}


module "distribution" {
  source                      = "./modules/distribution"
  bucket_endpoint             = module.app_bucket.website_endpoint
  bucket_regional_domain_name = module.app_bucket.bucket_regional_domain_name
}


module "build_stage_action" {
  source          = "./modules/buildstage"
  name            = var.codebuild_name
  distribution_id = module.distribution.distribution_id
}


module "invalidate_stage_action" {
  source          = "./modules/invalidatestage"
  name            = "${var.codebuild_name}-invalidate"
  distribution_id = module.distribution.distribution_id
}


module "code_pipeline" {
  source      = "./modules/codepipeline"
  name        = var.pipeline_name
  build_stage = var.codebuild_name
  cache_stage = "${var.codebuild_name}-invalidate"

  bucket = {
    bucket_name        = var.bucket_name
    bucket_id          = module.app_bucket.bucket_id
    bucket_website_arn = module.app_bucket.bucket_website_arn
  }

  github = {
    github_repo     = var.github_repo
    github_username = var.github_username
    github_token    = var.github_token
  }
}



output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.distribution.distribution_id
}

output "website_url" {
  description = "Website URL (HTTPS)"
  value       = module.distribution.domain_name
}

output "s3_url" {
  description = "S3 hosting URL (HTTP)"
  value       = module.app_bucket.website_endpoint
}
