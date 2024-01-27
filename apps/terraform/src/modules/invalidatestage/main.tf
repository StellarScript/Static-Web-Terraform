
resource "aws_codebuild_project" "build_project_invalidate" {
  name         = var.name
  service_role = aws_iam_role.invalidate_role.arn

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
    buildspec           = file("${path.module}/invalidate.yaml")
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

resource "aws_iam_role" "invalidate_role" {
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}


data "aws_iam_policy_document" "invalidate_policy" {
  statement {
    effect = "Allow"
    actions = [
      "logs:*",
      "cloudwatch:*",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds",
      "cloudfront:CreateInvalidation"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "invalidate_policy" {
  role   = aws_iam_role.invalidate_role.id
  policy = data.aws_iam_policy_document.invalidate_policy.json
}
