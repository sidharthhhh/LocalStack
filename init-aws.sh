# #!/bin/bash
# set -e

# echo "🚀 Starting to create AWS resources..."

# # Create S3 Bucket & SQS Queue
# awslocal s3 mb s3://my-test-bucket
# awslocal sqs create-queue --queue-name my-test-queue
# echo "✅ S3 & SQS created."

# # --- Create Lambda ---
# echo "📦 Packaging Lambda function..."
# cd /opt/code/lambda-src/
# zip deployment.zip lambda_function.py

# echo "🚀 Deploying Lambda function..."
# until awslocal lambda list-functions > /dev/null 2>&1; do
#   echo "Waiting for Lambda service to be ready..."
#   sleep 2
# done

# awslocal lambda create-function \
#   --function-name my-s3-processor \
#   --runtime python3.10 \
#   --handler lambda_function.lambda_handler \
#   --role arn:aws:iam::000000000000:role/lambda-role \
#   --zip-file fileb://deployment.zip

# # --- THIS IS THE NEW FIX ---
# echo "⏳ Waiting for Lambda function to become active..."
# awslocal lambda wait function-active-v2 --function-name my-s3-processor
# echo "✅ Lambda is active."
# # --- END OF FIX ---
    
# echo "🔗 Connecting S3 to Lambda..."
# awslocal lambda add-permission \
#   --function-name my-s3-processor \
#   --action "lambda:InvokeFunction" \
#   --principal s3.amazonaws.com \
#   --statement-id "s3-invoke-permission" \
#   --source-arn arn:aws:s3:::my-test-bucket

# awslocal s3api put-bucket-notification-configuration \
#   --bucket my-test-bucket \
#   --notification-configuration '{
#       "LambdaFunctionConfigurations": [
#         {
#           "LambdaFunctionArn": "arn:aws:lambda:us-east-1:000000000000:function:my-s3-processor",
#           "Events": ["s3:ObjectCreated:*"]
#         }
#       ]
#     }'
    
# echo "🎉 All resources created and configured!"