#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
source "$REPO_ROOT/.env"

cd "$SCRIPT_DIR/../terraform"
INSTANCE1_ID=$(terraform output vpc1_ec2_instance_id | sed 's/"//g')
INSTANCE1_HOSTNAME=$(terraform output vpc1_ec2_instance_hostname | sed 's/"//g')
INSTANCE1_PRIVATE_IPV4=$(terraform output vpc1_ec2_instance_private_ip | sed 's/"//g')
INSTANCE2_ID=$(terraform output vpc2_ec2_instance_id | sed 's/"//g')
INSTANCE2_PRIVATE_IPV4=$(terraform output vpc2_ec2_instance_private_ip | sed 's/"//g')
CGWD_PRIVATE_IPV4=$(terraform output customer_gateway_device_lan_ip | sed 's/"//g')

log() {
  printf '%s\n' "$@"
}

log "
INFO -
To run these tests you must first add the appropriate values to .onprem.env
(see .onprem.env.example) and run ./onprem-up.sh to bring up the simulated
on-premises network.

IPSEC tunnels must be in 'Status: Up' (see AWS console under 'Site-to-Site VPN connections').
"

log "Testing network connectivity between VPC1 instance $INSTANCE1_ID & VPC2 instance $INSTANCE2_ID"

CMD_ID=$(aws ssm send-command \
  --instance-ids "$INSTANCE1_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters commands="ping -c 1 -W 2 $INSTANCE2_PRIVATE_IPV4 &> /dev/null && echo success || echo error" \
  --query "Command.CommandId" \
  --region "$AWS_REGION" \
  --output text)

if aws ssm get-command-invocation \
  --command-id "$CMD_ID" \
  --instance-id "$INSTANCE1_ID" \
  --query "StandardOutputContent" \
  --region "$AWS_REGION" \
  --output text | grep -q 'success'; then
  log "SUCCESS - VPC1 instance $INSTANCE1_ID is able to reach VPC2 instance $INSTANCE2_ID"
else
  log "FAILURE- VPC1 instance $INSTANCE1_ID is unable to reach VPC2 instance $INSTANCE2_ID"
  exit
fi

log "Testing network connectivity between VPC1 instance $INSTANCE1_ID & the on-premises network ($CGWD_PRIVATE_IPV4)"

CMD_ID=$(aws ssm send-command \
  --instance-ids "$INSTANCE1_ID" \
  --document-name "AWS-RunShellScript" \
  --parameters commands="ping -c 1 -W 2 $CGWD_PRIVATE_IPV4 &> /dev/null && echo success || echo error" \
  --query "Command.CommandId" \
  --region "$AWS_REGION" \
  --output text)

if aws ssm get-command-invocation \
  --command-id "$CMD_ID" \
  --instance-id "$INSTANCE1_ID" \
  --query "StandardOutputContent" \
  --region "$AWS_REGION" \
  --output text | grep -q 'success'; then
  log "SUCCESS - VPC1 instance $INSTANCE1_ID is able to reach the on-premises network"
else
  log "FAILURE- VPC1 instance $INSTANCE1_ID is unable to reach the on-premises network"
  exit
fi

log "Testing DNS resolution between on-premises Customer Gateway Device ($CGWD_PRIVATE_IPV4) and AWS private network"

if docker exec -i cgw dig +noall +answer @$CGWD_PRIVATE_IPV4 $INSTANCE1_HOSTNAME | grep -q "$INSTANCE1_PRIVATE_IPV4"; then
  log "SUCCESS - on-premises DNS resolved VPC1 instance $INSTANCE1_ID private IP"
else
  log "FAILURE - on-premises DNS did not resolve VPC1 instance $INSTANCE1_ID private IP"
  exit
fi

log "All tests have been run successfully"