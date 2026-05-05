#!/bin/bash
set -e

AMI_ID="ami-0b223652c4ba856f8"

echo "=== STEP 1: Creating Security Group ==="
SG_ID=$(aws ec2 create-security-group \
  --group-name "packer-deploy-sg" \
  --description "Security group for automated deploy" \
  --query 'GroupId' \
  --output text)

echo "Security Group created: $SG_ID"

# Open port 22 (SSH)
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0

# Open port 80 (HTTP)
aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0

echo "=== STEP 2: Launching instance ==="
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.micro \
  --key-name packer-key \
  --security-group-ids $SG_ID \
  --associate-public-ip-address \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance launched: $INSTANCE_ID"

echo "=== STEP 3: Waiting for instance to be ready ==="
aws ec2 wait instance-running --instance-ids $INSTANCE_ID

PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)

echo ""
echo "=========================================="
echo "  DEPLOYMENT COMPLETED"
echo "  AMI: $AMI_ID"
echo "  Instance: $INSTANCE_ID"
echo "  Public IP: $PUBLIC_IP"
echo "  Access: http://$PUBLIC_IP"
echo "=========================================="
