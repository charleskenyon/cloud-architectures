#!/usr/bin/env bash

FUNCTION_NAME="lambda-canary-pipeline-app-lambda:live"

echo "Triggering intentional failure"

aws lambda invoke \
  --function-name "$FUNCTION_NAME" \
  --cli-binary-format raw-in-base64-out \
  --payload '{"deploymentTest":true,"isForceFailure":true}' \
  /dev/stdout

echo "Failure request sent"