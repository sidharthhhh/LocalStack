# --- 1. IAM ROLE FOR LAMBDA ---
# Lambda needs permission (a "role") to run. 
# This is a basic policy that lets it be "assumed" by the Lambda service.
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "lambda_exec_role" {
  name               = "my-tf-lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json


  depends_on = [aws_s3_bucket.lambda_bucket]
}

# --- 2. ZIP THE LAMBDA CODE ---
# This resource reads your Python file and creates a .zip file
# in memory for Terraform to use.
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda-src/lambda_function.py"
  output_path = "lambda_function.zip" # Creates this zip file locally
}

# --- 3. THE LAMBDA FUNCTION ---
# This creates the Lambda function using the role and the zip file.
resource "aws_lambda_function" "my_lambda" {
  function_name = "my-tf-s3-processor"
  role          = aws_iam_role.lambda_exec_role.arn
  runtime       = "python3.10"
  handler       = "lambda_function.lambda_handler" # "filename.function_name"
  
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# --- 4. LAMBDA PERMISSION ---
# This command gives the S3 service permission to run your Lambda.
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.lambda_bucket.arn # Points to the bucket in main.tf
}

# --- 5. S3 NOTIFICATION ---
# This is the final step! It tells the S3 bucket:
# "When a new file is created, run this Lambda function."
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lambda_bucket.bucket # Points to the bucket in main.tf
  
  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*"] # Trigger on file creation
  }
  
  # This tells Terraform: "You must create the permission
  # (step 4) before you try to create this notification."
  depends_on = [aws_lambda_permission.allow_s3]
}