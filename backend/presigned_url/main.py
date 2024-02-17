import boto3
import json
import random
import os

# Change this value to adjust the signed URL's expiration
URL_EXPIRATION_SECONDS = 300

# Main Lambda entry point
def lambda_handler(event, context):
    return get_upload_url(event)

def get_upload_url(event):
    s3 = boto3.client('s3')
    random_id = str(random.randint(1, 10000000))
    key = f"{random_id}-video.mp4"

    # Get signed URL from S3
    upload_url = s3.generate_presigned_post(Bucket=os.environ['UploadBucket'],
                                            Key=key,
                                            Fields={'acl': 'public-read'},
                                            Conditions=[{'acl': 'public-read'}],
                                            ExpiresIn=3600)
    objectURL = f"https://{os.environ['UploadBucket']}.s3.eu-north-1.amazonaws.com/{key}"
    
    responseBody = json.dumps({
        'uploadURL': upload_url,
        'Key': key,
        'objectURL': objectURL
        })
    response = {
            "statusCode": 200,
            "headers": {
                "content-type": "application/json; charset=utf-8"
            },
            "body": responseBody
        }

    return response
