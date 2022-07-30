import json
import urllib.parse
import boto3

print('Loading function')

s3 = boto3.client('s3', endpoint_url="http://localhost:4566", use_ssl=False, aws_access_key_id="foobar", aws_secret_access_key="foobar", region_name="eu-central-1")


def lambda_handler(event, context):
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    try:
        print("Filename: ", key)
        input= {
            'bucket_name': bucket_name,
            'file_key': file_key
        }
        
        stepFunction = boto3.client('stepfunctions', endpoint_url="http://localhost:4566", use_ssl=False, aws_access_key_id="foobar", aws_secret_access_key="foobar", region_name="eu-central-1")
        response = stepFunction.start_execution(
          stateMachineArn='arn:aws:states:eu-central-1:000000000000:stateMachine:sample-state-machine',
          input = json.dumps(input, indent=4)
        )
        return response
    except Exception as e:
        print(e)
        print('Error getting object {} from bucket {}. Make sure they exist and your bucket is in the same region as this function.'.format(key, bucket))
        raise e

