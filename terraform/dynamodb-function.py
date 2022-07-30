import boto3


def lambda_handler(event, context):
    key = event['file_key']
    try:
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

