import json
import urllib.parse
import boto3

print('Loading function')

s3 = boto3.client('s3', endpoint_url="http://localhost:4566", use_ssl=False, aws_access_key_id="foobar", aws_secret_access_key="foobar", region_name="eu-central-1")


def lambda_handler(event, context):
    #print("Received event: " + json.dumps(event, indent=2))

    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    try:
        #response = s3.get_object(Bucket=bucket, Key=key)
        #print("CONTENT TYPE: " + response['ContentType'])
        #return response['ContentType']
        print("Filename: ", key)
        dynamodb = boto3.resource('dynamodb', endpoint_url="http://localhost:4566", use_ssl=False, aws_access_key_id="foobar", aws_secret_access_key="foobar", region_name="eu-central-1")
        table = dynamodb.Table('Files')
        response = table.put_item(
          Item={
            'FileName': key,
          }
        )
        return response
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e

