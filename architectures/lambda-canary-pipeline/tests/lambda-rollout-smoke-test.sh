#!/usr/bin/env bash
set -e

FUNCTION_BASE="lambda-canary-pipeline-app-lambda"

# Get latest published version
LATEST_VERSION=$(aws lambda list-versions-by-function \
  --function-name "$FUNCTION_BASE" \
  --query 'Versions[-1].Version' \
  --output text)

FUNCTION_NAME="${FUNCTION_BASE}:${LATEST_VERSION}"

ITERATIONS=10
SLEEP_SECONDS=6

echo "Latest Lambda version detected: $LATEST_VERSION"
echo "Starting smoke test against $FUNCTION_NAME"

failures=0

for i in $(seq 1 $ITERATIONS); do
  echo "Test request $i"

  RESPONSE=$(aws lambda invoke \
    --function-name "$FUNCTION_NAME" \
    --cli-binary-format raw-in-base64-out \
    --payload '{"deploymentTest":true}' \
    /dev/stdout 2>/dev/null)

  echo "Response: $RESPONSE"

  if echo "$RESPONSE" | grep -q "error"; then
    echo "Error detected"
    failures=$((failures + 1))
  fi

  sleep "$SLEEP_SECONDS"
done

echo "Failures detected: $failures"

if [ "$failures" -gt 0 ]; then
  echo "Smoke test FAILED"
  exit 1
fi

echo "Smoke test PASSED"