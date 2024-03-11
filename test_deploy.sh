#!/bin/bash

# Deploy the template file which uses SAM syntax/transform, using the
# AWS CloudFormation CLI and without using the SAM CLI.
# This necessarily involves a brief S3 usage.
# Then invoke the function, then delete all resources used.

# Choose naming of resources:
export NAME_PREFIX="testDeploy"

##########################################################################

# Prevent terminal output waiting:
export AWS_PAGER=""

source create.sh clean
source create.sh stack

read -p "Press any key to continue... " -n1 -s; echo

echo Invoke the lambda twice
for i in {1..2}
do
    aws lambda invoke \
    --function-name $FUNCTION_NAME \
    --cli-binary-format raw-in-base64-out \
    --payload '{"time": "1970-01-01T00:00:00Z"}' \
    temp && cat temp; echo; rm -f temp
    sleep 2
done

read -p "Press any key to continue... " -n1 -s; echo

source create.sh clean
echo "Finished."
