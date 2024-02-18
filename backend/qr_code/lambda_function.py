import json
import boto3
import qrcode
import io
import base64
import os

# Initialize a session using Amazon S3
s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket=os.environ['UploadBucket']
    url = event['url']
    print(url)
    # Generate QR code
    img = qrcode.make(url)
    img_bytes = io.BytesIO()
    img.save(img_bytes)
    img_bytes = img_bytes.getvalue()
    
    # Generate a unique filename
    filename = url.split("://")[1].split("/")[-1].split("-")[0] + ".png"
    
    # Upload the QR code to the S3 bucket
    s3.put_object(Bucket=bucket, Key=filename, Body=img_bytes, ContentType='image/png', ACL='public-read')
    
    # Generate the URL of the uploaded QR code
    qr_code_url = f"https://s3-eu-north-1.amazonaws.com/{bucket}/{filename}"
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'QR code generated and uploaded to S3 bucket successfully!', 
        'qr_code_url': qr_code_url})
    }
