provider "aws" {
  access_key = "foobar"
  secret_key = "foobar"
  region     = "eu-central-1"

  s3_use_path_style           = true
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true


  endpoints {
    apigateway     = "http://localhost:4566"
    apigatewayv2   = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    cloudwatchlogs = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    ec2            = "http://localhost:4566"
    es             = "http://localhost:4566"
    elasticache    = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    rds            = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    route53        = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "bucket" {
    bucket = "test-bucket"
}

module "DynamoDb" {
  source = "./DynamoDb"
  table_name = "Files"
  attribute = "FileName"
  hash_key = "FileName"
}

data "aws_caller_identity" "current" {}

data "archive_file" "lambda_zip" {
    type          = "zip"
    source_file   = "lambda.py"
    output_path   = "lambda.zip"
}

resource "aws_lambda_function" "test_lambda" {
  function_name = "test_lambda"
  role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSRoleForLambda"
  handler = "lambda.lambda_handler"
  runtime = "python3.6"
  filename = "lambda.zip"
}

resource "aws_s3_bucket_notification" "aws-lambda-trigger" {
  bucket = "${aws_s3_bucket.bucket.id}"
  lambda_function {
    lambda_function_arn = "${aws_lambda_function.test_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}




# Create IAM role for AWS Step Function
resource "aws_iam_role" "iam_for_sfn" {
  name = "stepFunctionSampleStepFunctionExecutionIAM"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


resource "aws_iam_policy" "policy_publish_sns" {
  name        = "stepFunctionSampleSNSInvocationPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSNS",
            "Effect": "Allow",
            "Action": [
              "sns:Publish",
              "sns:SetSMSAttributes",
              "sns:GetSMSAttributes"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_policy" "policy_invoke_lambda" {
  name        = "stepFunctionSampleLambdaFunctionInvocationPolicy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowLamdaInvoke",
            "Effect": "Allow",
            "Action": [
                "lambda:InvokeFunction",
                "lambda:InvokeAsync"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_invoke_lambda" {
  role       = "${aws_iam_role.iam_for_sfn.name}"
  policy_arn = "${aws_iam_policy.policy_invoke_lambda.arn}"
}

resource "aws_iam_role_policy_attachment" "iam_for_sfn_attach_policy_publish_sns" {
  role       = "${aws_iam_role.iam_for_sfn.name}"
  policy_arn = "${aws_iam_policy.policy_publish_sns.arn}"
}

#Creating State Machine
resource "aws_sfn_state_machine" "sfn_state_machine" {
  name     = "sample-state-machine"
  role_arn = "${aws_iam_role.iam_for_sfn.arn}"

  definition = <<EOF
{
  "StartAt": "WriteToDB",
  "States": {
    "WriteToDB": 
    {
      "Type": "Task",
      "Resource": "${aws_lambda_function.dynamodb-function.arn}",
      "Next": "Success"
    }, 
  "Success": 
  {
     "Type": "Succeed"
  }
}
}
EOF
}


data "archive_file" "dynamodb_zip" {
    type          = "zip"
    source_file   = "dynamodb-function.py"
    output_path   = "dynamodb-function.zip"
}


resource "aws_lambda_function" "dynamodb-function" {
  function_name = "dynamodb-function"
  role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AWSRoleForLambda"
  handler = "dynamodb-function.lambda_handler"
  runtime = "python3.6"
  filename = "dynamodb-function.zip"
}
