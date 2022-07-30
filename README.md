# Technical Assignments

The goal of this assignment is to evaluate your ability to work with Terraform and AWS services. We expect that a developer with some experience should be able to solve this within one to two hours.

Please commit your results to GitHub and send us the URL to your repository, so we can review your work before the interview.

There are two assignments, one with focus on Terraform and one with focus on Cloudformation. So, we expect you to check in Terraform and Cloudformation template files. If you use additional helper frameworks to create the output files, please also check in the code you've written for these frameworks as well.

You'll find the two parts in the folders:
- terraform
- cloudformation

We've put together instructions in the README.md files in the two directories. All instructions have been tested on Ubuntu Linux. You are free to use other operating system as long as the checked in code can still be tested on Linux.


Have fun!




## Commented by Ali Panahi
I **solved** both tasks completely and committed my changes to https://github.com/ali-panahi/Swisscom


### Task 1: CloudFormation

#### 1. Clone the repositoty
```shell
git clone https://github.com/ali-panahi/Swisscom.git
```

#### 2. Change to cloudformation directory
```shell
cd Swisscom/cloudformation
```

#### 3. Run localstack
```shell
docker-compose up -d
```
#### 4. Create cloudformation stack
```shell
aws --endpoint-url http://localhost:4566 cloudformation create-stack --stack-name S3Swisscom --template-body file://stack.template --parameters 
```
```
ParameterKey=BucketName,ParameterValue=swisscom
  {
      "StackId": "arn:aws:cloudformation:eu-central-1:000000000000:stack/S3Swisscom/f50dccbd"
  }
```

#### 5. List S3 buckets
```shell
aws --endpoint-url http://localhost:4566 s3api list-buckets
```
```
  {
      "Buckets": [
          {
              "Name": "s3swisscom-loggingbucket-ec5228f9",
              "CreationDate": "2022-07-29T09:46:45.000Z"
          },
          {
              "Name": "swisscom-s3",
              "CreationDate": "2022-07-29T09:46:45.000Z"
          }
      ],
      "Owner": {
          "DisplayName": "webfile",
          "ID": "bcaf1ffd86f41161ca5fb16fd081034f"
      }
  }
```

#### 6. Create a file in S3 bucket
```shell
aws --endpoint-url http://localhost:4566 s3 cp README.md s3://swisscom-s3
```
*upload: ./README.md to s3://swisscom-s3/README.md*

#### 7. List Files in bucket
```shell
aws --endpoint-url http://localhost:4566 s3 ls s3://swisscom-s3 --recursive --human-readable --summarize
```
```
  2022-07-29 14:22:08    1.4 KiB README.md

  Total Objects: 1
    Total Size: 1.4 KiB
```

#### 8. Bring down localstack
```shell
docker-compose down
```



### Task 2: Terrafrom

#### 1. Clone the repositoty
```shell
git clone https://github.com/ali-panahi/Swisscom.git
```

#### 2. Change to terrafrom directory
```shell
cd Swisscom/terraform
```

#### 3. Run localstack
```shell
docker-compose up -d
```

#### 4. Run terraform to deploy your tasks
```shell
- terraform init
- terraform plan
- terraform apply
```
  *Apply complete! Resources: 11 added, 0 changed, 0 destroyed.*

#### 5. List state machines
```shell
aws --endpoint-url http://localhost:4566 stepfunctions list-state-machines
```
```
{
    "stateMachines": [
        {
            "stateMachineArn": "arn:aws:states:eu-central-1:000000000000:stateMachine:sample-state-machine",
            "name": "sample-state-machine",
            "type": "STANDARD",
            "creationDate": "2022-07-30T15:37:58.052000+04:30"
        }
    ]
}
```

#### 6. Create a file in S3 bucket
```shell
aws --endpoint-url http://localhost:4566 s3 cp README.md s3://test-bucket
```
*upload: ./README.md to s3://test-bucket/README.md*

#### 7. Get all items in Dynamodb
```shell
aws --endpoint-url http://localhost:4566 dynamodb scan --table-name Files
```
```
{
    "Items": [
        {
            "FileName": {
                "S": "README.md"
            }
        }
    ],
    "Count": 1,
    "ScannedCount": 1,
    "ConsumedCapacity": null
}
```


>Note: I just configure trigger work flow for just creating file on S3 bucket.
