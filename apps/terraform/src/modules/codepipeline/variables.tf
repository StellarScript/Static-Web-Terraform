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


variable "codestart_connection" {
  sensitive = true
  type      = string
}

variable "repository_id" {
  type = string
}