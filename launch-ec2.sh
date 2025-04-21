#!/bin/bash

set -e  # Exit if any command fails
source config.cfg

LOG_FILE="logs/launch.log"
mkdir -p logs  # Ensure logs dir exists

echo "🚀 Launching EC2 instance..."

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --count 1 \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SECURITY_GROUP_ID" \
  --subnet-id "$SUBNET_ID" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
  --query "Instances[0].InstanceId" \
  --output text) || { echo "❌ Failed to launch EC2 instance"; exit 1; }

echo "✅ Instance launched: $INSTANCE_ID"
echo "⏳ Waiting for instance to be running..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"

# Get Public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "🌐 Public IP: $PUBLIC_IP"
echo "⏳ Waiting for SSH availability..."
sleep 30

# Install Docker
echo "📦 Installing Docker on $PUBLIC_IP..."
ssh -o StrictHostKeyChecking=no -i "~/.ssh/$KEY_NAME.pem" ec2-user@$PUBLIC_IP << 'EOF'
  sudo yum update -y
  sudo amazon-linux-extras install docker -y
  sudo service docker start
  sudo usermod -aG docker ec2-user
EOF

echo "✅ Docker installed!"
echo "🔗 Connect to your instance with:"
echo "ssh -i ~/.ssh/$KEY_NAME.pem ec2-user@$PUBLIC_IP"

# Log it
echo "$(date '+%Y-%m-%d %H:%M:%S') | Launched: $INSTANCE_ID | IP: $PUBLIC_IP" >> "$LOG_FILE"

