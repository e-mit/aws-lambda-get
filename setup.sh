#!/bin/bash

# Name prefix for the resources to be created:
NAME_PREFIX=testget

# Time period for the lambda repetition:
CYCLE_PERIOD_VALUE=1
CYCLE_PERIOD_UNIT=minute

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
"timePeriodValue=$CYCLE_PERIOD_VALUE \
timePeriodUnit=$CYCLE_PERIOD_UNIT queueARN=$QUEUE_ARN \
timeout=$LAMBDA_TIMEOUT_SEC"

# Add environment variables to the lambda
aws lambda update-function-configuration \
--function-name $FUNCTION_NAME \
--environment "Variables={LOG_LEVEL=$LOG_LEVEL, \
GET_URL=$GET_URL, GET_TIMEOUT_SEC=$GET_TIMEOUT_SEC}" &> /dev/null

# Now enable the lambda's schedule, preserving the other parameters:
NEW_SCHEDULE_FILE=new_sched_temp.json
aws scheduler get-schedule \
--name $FUNCTION_NAME-schedule | \
python3 -c \
"import sys, json
sched = json.load(sys.stdin)
new_sched = {'State': 'ENABLED'}
for k in ['FlexibleTimeWindow','ScheduleExpression','Target','Name']:
    new_sched[k] = sched[k]
print(json.dumps(new_sched))" > $NEW_SCHEDULE_FILE
aws scheduler update-schedule \
--cli-input-json file://$NEW_SCHEDULE_FILE &> /dev/null
rm -f $NEW_SCHEDULE_FILE
