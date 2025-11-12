# LocalStack
for aws service testing

------------------------project-1--------------------------------------------
Project 1:- Build the classic "Hello, World!" of serverless: an S3-to-Lambda trigger
Make sure to have aws cli install in your system. :- 
add this line your docker volume:- - ./lambda-src:/opt/code/lambda-src

Run this command:- 
docker-compose exec localstack bash -c " \
  cd /opt/code/lambda-src/ && \
  zip deployment.zip lambda_function.py && \
  awslocal lambda create-function \
    --function-name my-s3-processor \
    --runtime python3.10 \
    --handler lambda_function.lambda_handler \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --zip-file fileb://deployment.zip \
"

-> tell S3 to send events to the Lambda.

->Give S3 permission to run your Lambda:
docker-compose exec localstack awslocal lambda add-permission \
  --function-name my-s3-processor \
  --action "lambda:InvokeFunction" \
  --principal s3.amazonaws.com \
  --statement-id "s3-invoke-permission" \
  --source-arn arn:aws:s3:::my-test-bucket


-> Tell the S3 bucket to send the event:
docker-compose exec localstack awslocal s3api put-bucket-notification-configuration \
  --bucket my-test-bucket \
  --notification-configuration '{
      "LambdaFunctionConfigurations": [
        {
          "LambdaFunctionArn": "arn:aws:lambda:us-east-1:000000000000:function:my-s3-processor",
          "Events": ["s3:ObjectCreated:*"]
        }
      ]
    }'

-> Test
-> Create a dummy file on your local machine:
echo "This is my test file" > test.txt

-> Upload the file using the official aws CLI.
aws s3 cp test.txt s3://my-test-bucket/test.txt --endpoint-url=http://localhost:4566

-> see localstack logs
docker-compose logs localstack

"...
localstack  | --- EVENT RECEIVED ---
localstack  | File: test.txt
localstack  | Bucket: my-test-bucket
localstack  | {
localstack  |   "Records": [
localstack  |     {
localstack  |       "s3": {
localstack  |         "bucket": {
localstack  |           "name": "my-test-bucket",
localstack  |           ...
localstack  |         },
localstack  |         "object": {
localstack  |           "key": "test.txt",
localstack  |           ...
localstack  |         }
localstack  |       }
localstack  |     }
localstack  |   ]
localstack  | }
localstack  | --- EVENT PROCESSED ---
..."
----------------------------------------proejct ended----------------------