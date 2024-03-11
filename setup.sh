#!/bin/bash

# Name prefix for the resources to be created:
NAME_PREFIX=testget

# Time period string for the lambda repetition:
CYCLE_PERIOD='1 minute'

# Name of the SQS queue for output:
QUEUE_NAME="test1Stackddfa8b-queue-Cmn2pmetTKtl"

# Lambda timeout:
LAMBDA_TIMEOUT_SEC=10

# Parameters for the GET function:
LOG_LEVEL='DEBUG'
GET_URL="https://api.carbonintensity.org.uk/intensity"
GET_TIMEOUT_SEC=5

####################################################

source create.sh clean

QUEUE_URL=$(aws sqs list-queues \
--queue-name-prefix $QUEUE_NAME | \
python3 -c \
"import sys, json
print(json.load(sys.stdin)['QueueUrls'][0])")

QUEUE_ARN=$(aws sqs get-queue-attributes \
--queue-url $QUEUE_URL \
--attribute-names QueueArn | \
python3 -c \
"import sys, json
print(json.load(sys.stdin)['Attributes']['QueueArn'])")

source create.sh stack \
"timePeriod=$CYCLE_PERIOD queueARN=$QUEUE_ARN \
timeout=$LAMBDA_TIMEOUT_SEC"

# Add environment variables to the lambda
aws lambda update-function-configuration \
--function-name $FUNCTION_NAME \
--environment "Variables={LOG_LEVEL=$LOG_LEVEL, \
GET_URL=$GET_URL, GET_TIMEOUT_SEC=$GET_TIMEOUT_SEC}"
