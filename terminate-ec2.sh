#!/bin/bash

set -e
source config.cfg

LOG_FILE="logs/terminate.log"
mkdir -p logs

read -p "🔍 Enter the EC2 Instance ID to terminate: " INSTANCE_ID

if [[ -z "$INSTANCE_ID" ]]; then
  echo "❌ Instance ID cannot be empty."
  exit 1
fi

# Terminate the instance
echo "⚙️ Terminating instance $INSTANCE_ID ..."
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID" > /dev/null

# Wait until it's terminated
echo "⏳ Waiting for termination to complete..."
aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"

echo "✅ Instance $INSTANCE_ID terminated."

# Log the action
TODAY=$(date '+%Y-%m-%d')
LOG_DIR="logs/terminate"
LOG_FILE="$LOG_DIR/terminate-$TODAY.log"
mkdir -p "$LOG_DIR"

echo "$(date '+%Y-%m-%d %H:%M:%S') | Terminated: $INSTANCE_ID" >> "$LOG_FILE"

