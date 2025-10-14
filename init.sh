#!/bin/bash

AWS_PROFILE=YOUR_PROFILE aws s3api create-bucket \
  --bucket YOUR_TERRAFORM_STATE_AWS_S3_BUCKET \
  --region YOUR_REGION \
  --create-bucket-configuration LocationConstraint=YOUR_REGION

AWS_PROFILE=YOUR_PROFILE aws dynamodb create-table \
  --table-name YOUR_TERRAFORM_DYNAMODB_LOCKS_TABLE \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region YOUR_REGION
