resource "aws_iam_role" "codebuild_role" {
  name = "${var.arch}-codebuild-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "${var.arch}-codebuild-policy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.s3_codepipeline_bucket.arn,
          "${aws_s3_bucket.s3_codepipeline_bucket.arn}/*"
        ]
      },
      {
        Sid    = "ECRAuthPolicy"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:BatchGetImage"
        ]
        Resource = [
          aws_ecr_repository.ecr_container_repo.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:GetAlias",
          "lambda:UpdateFunctionCode",
          "lambda:Wait",
          "lambda:GetFunctionConfiguration",
          "lambda:PublishVersion"
        ]
        Resource = [
          module.app[0].function_arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${var.arch}-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "${var.arch}-codepipeline-policy"
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetObjectVersion",
          "s3:GetBucketVersioning"
        ]
        Resource = [
          aws_s3_bucket.s3_codepipeline_bucket.arn,
          "${aws_s3_bucket.s3_codepipeline_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetRepository",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ]
        Resource = [
          aws_codecommit_repository.deployment_repo.arn
        ]
      },
      # {
      #   Effect = "Allow"
      #   Action = [
      #     "codedeploy:CreateDeployment",
      #     "codedeploy:GetApplication",
      #     "codedeploy:GetDeployment",
      #     "codedeploy:RegisterApplicationRevision",
      #     "codedeploy:ListDeployments",
      #     "codedeploy:ListDeploymentGroups",
      #     "codedeploy:GetDeploymentGroup"
      #   ]
      #   Resource = [
      #     aws_codedeploy_app.codedeploy_app.arn,
      #     aws_codedeploy_deployment_group.codedeploy_deployment_group.arn
      #   ]
      # },
      # {
      #   Effect = "Allow"
      #   Action = [
      #     "codedeploy:GetDeploymentConfig"
      #   ]
      #   Resource = [
      #     "*"
      #   ]
      # },
      # {
      #   Effect = "Allow"
      #   Action = [
      #     "codedeploy:ListDeploymentConfigs"
      #   ]
      #   Resource = [
      #     "*"
      #   ]
      # },
      {
        Effect = "Allow"
        Action = [
          "lambda:GetAlias",
          "lambda:GetFunctionConfiguration",
          "lambda:GetProvisionedConcurrencyConfig",
          "lambda:PublishVersion",
          "lambda:UpdateAlias",
          "lambda:UpdateFunctionCode"
        ]
        Resource = [
          module.app[0].function_arn,
          "${module.app[0].function_arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
    ]
  })
}

# resource "aws_iam_role" "codedeploy_role" {
#   name = "${var.arch}-codedeploy-role"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "codedeploy.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
#   role       = aws_iam_role.codedeploy_role.name
# }

# resource "aws_iam_role_policy" "codedeploy_policy" {
#   name = "${var.arch}-codedeploy-policy"
#   role = aws_iam_role.codedeploy_role.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject",
#           "s3:GetObjectVersion",
#           "s3:GetBucketVersioning"
#         ]
#         Resource = [
#           aws_s3_bucket.s3_codepipeline_bucket.arn,
#           "${aws_s3_bucket.s3_codepipeline_bucket.arn}/*"
#         ]
#     }]
#   })
# }