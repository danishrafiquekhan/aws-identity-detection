#!/bin/bash
# Simulates a common IAM privilege-escalation pattern against LocalStack
# (never against a real AWS account): create a low-priv-looking user, then
# immediately self-attach an administrator policy and mint an access key.
#
# Usage: ./simulate-privesc.sh   (LocalStack must already be running:
#   cd ~/securitylab/localstack && docker compose up -d)
set -euo pipefail

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1
ENDPOINT="http://localhost:4566"

USERNAME="app-service-account-$(date +%s)"

echo "[1] Creating user: $USERNAME"
aws --endpoint-url="$ENDPOINT" iam create-user --user-name "$USERNAME" >/dev/null

echo "[2] Immediately attaching AdministratorAccess (the escalation step)"
aws --endpoint-url="$ENDPOINT" iam attach-user-policy \
  --user-name "$USERNAME" \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo "[3] Minting an access key (persistence step)"
aws --endpoint-url="$ENDPOINT" iam create-access-key --user-name "$USERNAME" >/dev/null

echo ""
echo "Done. Simulated events for: $USERNAME"
echo "This sequence (create user -> attach admin policy -> create access key,"
echo "all within seconds) is the pattern detections/privesc-detection.md is"
echo "written against."
