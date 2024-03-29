terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}



resource "aws_codebuild_project" "build_project" {
  name         = var.name
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "DISTRIBUTION_ID"
      value = var.distribution_id
    }

    # dynamic "environment_variable" {
    #   for_each = var.environment_variables
    #   content {
    #     name  = environment_variable.key
    #     value = environment_variable.value
    #   }
    # }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "loggroupname"
      stream_name = "/codebuild/${var.name}"
    }
  }

  source {
    type                = "CODEPIPELINE"
    buildspec           = file("${path.module}/buildspec.yaml")
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
  }
}


data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}


data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "logs:*",
      "cloudwatch:*",
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild_policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_policy.json
}
