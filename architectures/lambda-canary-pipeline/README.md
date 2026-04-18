# Lambda Canary Pipeline

## Overview

A Lambda container release pipeline that tests and builds a Lambda container using the Lambda Runtime Interface Emulator before publishing the image to ECR. The pipeline then triggers a canary rollout (`Canary10Percent5Minutes`) using weighted aliases. The pipeline monitors a CloudWatch alarm for Lambda errors and abandons the release if any errors are detected. The pipeline uses AWS CodePipeline and AWS CodeDeploy, and the artifacts are encrypted using KMS.

## Architecture

- AWS CodePipeline, AWS CodeDeploy, AWS CodeCommit, AWS Lambda, AWS ECR, AWS KMS, AWS S3, AWS CloudWatch, AWS IAM roles for CodePipeline & CodeDeploy

## Prerequisites

Terraform, user or role-based access to an AWS account (with permission to create the resources outlined above and local AWS CLI access).

## Quick Start

To begin, ensure that the Terraform variable `create_lambda` (in architectures/lambda-canary-pipeline/terraform/variables.tf) is set to `false` and deploy the platform infrastructure from the repository root:

```
make arch=lambda-canary-pipeline

make apply arch=lambda-canary-pipeline
```

Once the infrastructure has been deployed Terraform will output `build_repo_url`. Add the AWS Codecommit repository address as a remote and push to it:

```
`git remote set-url origin --push --add https://git-codecommit.us-east-1.amazonaws.com/v1/repos/lambda-canary-pipeline-repo
```

See the AWS documentation for setup steps for HTTPS connections to CodeCommit: [Setup steps for HTTPS connections to AWS CodeCommit](https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-windows.html#setting-up-https-windows-credential-helper)

This push will trigger a CodePipeline event that builds the Lambda image and pushes it to ECR. The pipeline will fail at the step where the image is published to Lambda, as the Lambda function does not exist yet.

Next, set the Terraform variable `create_lambda` to `true` and redeploy the platform infrastructure from the repository root. This bootstrap step will create the Lambda infrastructure, and once complete the pipeline will be ready for testing.

## Deployment Validation

Trigger a CodePipeline execution either by pushing to the repository or manually triggering it in the AWS console. Monitor the stages in the console. When the Deploy stage is reached, run:

```
make test arch=lambda-canary-pipeline
```

To test the rollback functionality, run the pipeline again and run `make lambda-canary-force-failure` at the `Deploy` stage to intentioanlly trigger a canary rollback and pipeline failure.

## Local Testing

To run the Lambda locally, navigate to architectures/lambda-canary-pipeline/lambda and run:

- `docker buildx build --platform linux/amd64 --provenance=false -t lambda-ts:test .` - to build the image.

- `docker run --platform linux/amd64 -p 9000:8080 lambda-ts:test
curl "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{}'` - to run the Lambda locally inside the Runtime Interface Emulator.
