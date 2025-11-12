import json

def lambda_handler(event, context):
    """
    This function is triggered by S3.
    It prints the event details to the Localstack logs.
    """
    print("--- EVENT RECEIVED ---")
    
    # The event from S3 is in the 'Records'
    for record in event.get('Records', []):
        bucket_name = record.get('s3', {}).get('bucket', {}).get('name')
        object_key = record.get('s3', {}).get('object', {}).get('key')
        
        if bucket_name and object_key:
            print(f"File: {object_key}")
            print(f"Bucket: {bucket_name}")
        
    print(json.dumps(event, indent=2))
    print("--- EVENT PROCESSED ---")
    
    return {
        'statusCode': 200,
        'body': json.dumps('Event processed successfully!')
    }