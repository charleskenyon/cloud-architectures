#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$REPO_ROOT/.env"

cd "$SCRIPT_DIR/../terraform"
PRIMARY_APP_ASG_ID=$(terraform output app_us_east_1_asg_id | sed 's/"//g')
SECONDARY_APP_ASG_ID=$(terraform output app_eu_west_2_asg_id | sed 's/"//g')
DOMAIN=$(terraform output -raw domain)

echo "Domain: $DOMAIN"

extract_hostname() {
  curl -s --max-time 5 "http://$DOMAIN" \
    | sed -n 's/.*Hello from \([^<]*\)<\/h1>.*/\1/p'
}

# get primary instance and hostname

PRIMARY_INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names "$PRIMARY_APP_ASG_ID" \
  --query "AutoScalingGroups[0].Instances[0].InstanceId" \
  --output text)

PRIMARY_HOSTNAME=$(aws ec2 describe-instances \
  --instance-ids "$PRIMARY_INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PrivateDnsName" \
  --output text)

echo "Primary hostname: $PRIMARY_HOSTNAME"

# verify primary app instance is serving traffic

echo "Checking primary app instance is serving traffic..."

CURRENT_HOST=$(extract_hostname)

echo "Response hostname: $CURRENT_HOST"

if [[ "$CURRENT_HOST" == "$PRIMARY_HOSTNAME" ]]; then
  echo "domain resolves to primary app instance"
else
  echo "domain not resolvable"
  exit 1
fi

# crash primary app instance server - trigger failover

echo "Triggering failover..."

aws ssm send-command \
  --instance-ids "$PRIMARY_INSTANCE_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters commands="sudo systemctl stop httpd" \
  >/dev/null

# wait for failover

echo "Waiting for DNS failover..."

sleep 60

ATTEMPTS=0
MAX_ATTEMPTS=8

SECONDARY_INSTANCE_ID=$(aws autoscaling describe-auto-scaling-groups \
  --region eu-west-2 \
  --auto-scaling-group-names "$SECONDARY_APP_ASG_ID" \
  --query "AutoScalingGroups[0].Instances[0].InstanceId" \
  --output text)

SECONDARY_HOSTNAME=$(aws ec2 describe-instances \
  --region eu-west-2 \
  --instance-ids "$SECONDARY_INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PrivateDnsName" \
  --output text)

echo "Expected secondary hostname: $SECONDARY_HOSTNAME"

while [[ $ATTEMPTS -lt $MAX_ATTEMPTS ]]; do
  CURRENT_HOST=$(extract_hostname)

  echo "Attempt $ATTEMPTS on $CURRENT_HOST"

  if [[ "$CURRENT_HOST" == "$SECONDARY_HOSTNAME" ]]; then
    echo "failover successful - domain resolves to secondary app instance"
    exit 0
  fi

  sleep 45
  ((ATTEMPTS++))
done