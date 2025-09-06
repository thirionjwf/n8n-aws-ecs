#!/bin/bash

AWS_PROFILE=your-profile aws s3api create-bucket \
  --bucket your_bucket_name \
  --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1

AWS_PROFILE=your-profile aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region eu-west-1
