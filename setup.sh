#!/bin/bash

# Name prefix for the resources to be created:
NAME_PREFIX=testget

# Time period string for the lambda repetition:
CYCLE_PERIOD='1 minute'

# Name of the SQS queue for output:
QUEUE_NAME="test1Stackddfa8b-queue-Cmn2pmetTKtl"

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
"timePeriod=$CYCLE_PERIOD queueARN=$QUEUE_ARN"
