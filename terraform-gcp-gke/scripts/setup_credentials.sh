#!/bin/bash

set -e

# Check if source path is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/your/service-account.json"
  exit 1
fi

SOURCE_CREDS=$1

# Create credentials directory
mkdir -p credentials

# Copy credentials file to the proper location
cp "$SOURCE_CREDS" "./credentials/service-account.json"

echo "Credentials set up successfully at ./credentials/service-account.json"
echo "You can now run 'terraform init' and 'terraform plan'"
