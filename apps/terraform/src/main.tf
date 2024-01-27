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
