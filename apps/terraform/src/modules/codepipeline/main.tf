

resource "aws_iam_role_policy" "pipeline_policy" {
  name   = "bucket_policy"
  role   = aws_iam_role.pipeline_role.id
  policy = data.aws_iam_policy_document.pipeline_policy.json
}


resource "aws_codepipeline" "codepipeline" {
  name     = var.name
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = var.bucket.bucket_name
    type     = "S3"

    # encryption_key {
    #   id   = data.aws_kms_alias.s3kmskey.arn
    #   type = "KMS"
    # }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        Owner      = var.github.github_username
        Repo       = var.github.github_repo
        OAuthToken = var.github.github_token
        Branch     = "main"
        # PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["OutputArtifact"]
      version          = "1"

      configuration = {
        ProjectName = var.build_stage
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        BucketName = var.bucket.bucket_name
        Extract    = "true"
      }
    }
  }

  stage {
    name = "Cache"

    action {
      name            = "Cache"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version         = "1"

      configuration = {
        ProjectName = var.cache_stage
      }
    }
  }
}


data "aws_iam_policy_document" "assume_pipeline_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}


resource "aws_iam_role" "pipeline_role" {
  name               = "bucket_role"
  assume_role_policy = data.aws_iam_policy_document.assume_pipeline_role.json
}


data "aws_iam_policy_document" "pipeline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "logs:*",
      "cloudwatch:*",
    ]
    resources = ["*"]
  }
}
