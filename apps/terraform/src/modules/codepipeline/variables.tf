variable "name" {
  type = string
}


variable "build_stage" {
  type = string
}


variable "cache_stage" {
  type = string
}


variable "bucket" {
  type = object({
    bucket_name        = string
    bucket_id          = string
    bucket_website_arn = string
  })
}


variable "github" {
  sensitive = true
  type = object({
    github_username = string
    github_repo     = string
    github_token    = string
  })
}
