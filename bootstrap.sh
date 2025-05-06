#!/bin/bash

set -e

echo "🔄 Updating system packages..."
sudo yum update -y

echo "🐳 Installing Docker..."
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -aG docker ec2-user

echo "🛠️ Installing Dev Tools..."
sudo yum install -y git docker-compose htop tree

echo "🖥️ Setting hostname..."
sudo hostnamectl set-hostname cloudpilot-node
echo "127.0.0.1   cloudpilot-node" | sudo tee -a /etc/hosts

