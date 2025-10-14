#!/bin/bash

AWS_PROFILE=<your-profile> aws s3api create-bucket \
  --bucket <your-terraform-state-aws-s3-bucket> \
  --region <your-region> \
  --create-bucket-configuration LocationConstraint=<your-region>

AWS_PROFILE=<your-profile> aws dynamodb create-table \
  --table-name <your-terraform-dynamodb-locks-table> \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region <your-region>
