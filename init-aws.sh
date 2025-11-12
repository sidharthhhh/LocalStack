#!/bin/bash

# This is the CLI for interacting with Localstack
# It's a wrapper around the normal 'aws' CLI
echo "🚀 Starting to create AWS resources..."

# Create an S3 Bucket
awslocal s3 mb s3://my-test-bucket
echo "✅ S3 bucket 'my-test-bucket' created."

# Create an SQS Queue
awslocal sqs create-queue --queue-name my-test-queue
echo "✅ SQS queue 'my-test-queue' created."

echo "🎉 All resources created."