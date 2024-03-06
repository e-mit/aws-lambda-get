#!/bin/bash

# Deploy a template file which uses SAM syntax/transform, using the
# AWS CloudFormation CLI and without using the SAM CLI.
# This necessarily involves a brief S3 usage.

# NB: some of these names must be alphanumeric only
RAND_ID=$(dd if=/dev/random bs=8 count=1 2>/dev/null \
          | od -An -tx1 | tr -d ' \t\n')
FUNCTION_NAME="testFunction$RAND_ID"
STACK_NAME="testStack$RAND_ID"
BUCKET_NAME="testbucket$RAND_ID" # Lower case only

echo Make an S3 bucket
aws s3 mb s3://$BUCKET_NAME

rm -rf function/__pycache__
rm -f function/*.pyc out.yml

echo Zip and upload the lambda code to the S3 bucket
# This returns an edited template with the S3 paths in place
# of local folders.
aws cloudformation package \
--template-file template.yml \
--s3-bucket $BUCKET_NAME \
--output-template-file out.yml

echo Now create the stack
# This will create OR update depending on whether the name already exists.
# Can use --no-execute-changeset to just preview what will happen.
aws cloudformation deploy \
--template-file out.yml \
--stack-name $STACK_NAME \
--capabilities CAPABILITY_NAMED_IAM \
--parameter-overrides functionName=$FUNCTION_NAME

read -p "Press any key to continue... " -n1 -s; echo

echo Delete the S3 bucket
aws s3 rb --force s3://$BUCKET_NAME

echo Invoke the lambda
aws lambda invoke \
--function-name $FUNCTION_NAME \
--cli-binary-format raw-in-base64-out \
--payload '{"time": "1970-01-01T00:00:00Z"}' \
temp && cat temp; echo; rm -f temp

read -p "Press any key to continue... " -n1 -s; echo

echo "Delete the stack and all its resources (lambda and role)"
aws cloudformation delete-stack --stack-name $STACK_NAME

echo "Delete the log group (was automatically created but is not in the stack)"
aws logs delete-log-group --log-group-name /aws/lambda/$FUNCTION_NAME

echo "Finished."
