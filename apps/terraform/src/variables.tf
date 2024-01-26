variable "bucket_name" {
  type = string
}


variable "pipeline_name" {
  type = string
}


variable "codebuild_name" {
  type = string
}


variable "github_username" {
  sensitive = true
  type      = string
}


variable "github_repo" {
  sensitive = true
  type      = string
}


variable "github_token" {
  sensitive = true
  type      = string
}
