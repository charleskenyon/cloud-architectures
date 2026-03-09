locals {
  app_function_name = "${var.arch}-app-lambda"
}

resource "aws_codecommit_repository" "deployment_repo" {
  repository_name = "${var.arch}-repo"
  description     = "repo for ${var.arch}"

  lifecycle {
    prevent_destroy = true
  }
}

module "app" {
  count  = var.create_lambda ? 1 : 0
  source = "../../../common/terraform/modules/lambda"

  function_name  = local.app_function_name
  function_image = aws_ecr_repository.ecr_container_repo.repository_url
  handler        = "index.handler"
}

resource "aws_lambda_alias" "app_live_alias" {
  count            = var.create_lambda ? 1 : 0
  name             = "live"
  function_name    = module.app[0].function_arn
  function_version = "1"
}

resource "aws_codepipeline" "codepipeline" {
  name     = "${var.arch}-app-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.s3_codepipeline_bucket.bucket
    type     = "S3"

    # no encryption_key -> uses default AWS-managed S3 key, for real-world usuage KMS CMK should be provided 
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.deployment_repo.repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "TerraformBuild"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_build.name
      }
    }
  }
}

resource "aws_codebuild_project" "codebuild_build" {
  name         = "${var.arch}-codebuild-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "IMAGE_REPO_URL"
      value = aws_ecr_repository.ecr_container_repo.repository_url
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.deployment_account
    }

    environment_variable {
      name  = "APP_LAMBDA_NAME"
      value = local.app_function_name
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name = "${var.arch}-build-logs"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "architectures/blue-green-deployment/lambda/buildspec.yml"
  }
}