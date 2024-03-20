#!/bin/bash

# Create a stack instance according to the parameters supplied in the
# environment variables. For an example configuration, see example_config.sh

####################################################

source create.sh clean

# Get the queue ARN by converting the name to a URL then to an ARN
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

# Create all resources but without enabling the lambda schedule
source create.sh stack \
"timePeriodValue=$CYCLE_PERIOD_VALUE \
timePeriodUnit=$CYCLE_PERIOD_UNIT queueARN=$QUEUE_ARN \
timeout=$LAMBDA_TIMEOUT_SEC"

# Add environment variables to the lambda
aws lambda update-function-configuration \
--function-name $FUNCTION_NAME \
--environment "Variables={LOG_LEVEL=$LOG_LEVEL, \
GET_URL=$GET_URL, GET_TIMEOUT_SEC=$GET_TIMEOUT_SEC}" &> /dev/null

# Now enable the lambda's schedule, preserving the other parameters
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
