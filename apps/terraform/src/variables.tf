variable "bucket_name" {
  type = string
}


variable "pipeline_name" {
  type = string
}


variable "codebuild_name" {
  type = string
}


variable "codestart_connection" {
  sensitive = true
  type      = string
}

variable "repository_id" {
  type = string
}