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
  source          = "./modules/codebuild"
  name            = var.codebuild_name
  distribution_id = module.distribution.distribution_id
}
