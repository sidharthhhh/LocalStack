# Resource 1: The S3 bucket that will trigger our Lambda
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "my-terraform-trigger-bucket"
  force_destroy = true
  
  # This line creates the dependency chain
  # It waits for the queue to be made first
  depends_on = [aws_sqs_queue.my_queue]
}

# Resource 2: The SQS queue
resource "aws_sqs_queue" "my_queue" {
  name = "my-terraform-queue"
}

# Resource 3: The EC2 instance
resource "aws_instance" "my_test_instance" {
  ami           = "ami-00000000000000001" 
  instance_type = "t2.micro"

  tags = {
    Name = "My-Test-Instance"
  }
  
  # This line waits for the S3 bucket to be made first
  depends_on = [aws_s3_bucket.lambda_bucket]
}