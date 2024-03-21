NAME_PREFIX=github

RAND_ID=$(dd if=/dev/random bs=10 count=1 2>/dev/null \
            | od -An -tx1 | tr -d ' \t\n')

############ Make an SQS queue
QUEUE_NAME=$NAME_PREFIX-queue-$RAND_ID

aws sqs create-queue \
--queue-name $QUEUE_NAME &> /dev/null

sleep 5

############ Create the stack and wait for data
STACK_NAME=$NAME_PREFIX-stack-$RAND_ID
CYCLE_PERIOD_VALUE=1
CYCLE_PERIOD_UNIT=minute
LAMBDA_TIMEOUT_SEC=10
LOG_LEVEL='DEBUG'
GET_URL="https://api.carbonintensity.org.uk/intensity"
GET_TIMEOUT_SEC=5

source setup.sh
sleep 90

############ Check events in the queue
aws sqs receive-message \
--queue-url $QUEUE_URL \
--max-number-of-messages 1 | python3 tests/cloud_test.py
RESULT=$?

############ Delete all resources
source stack.sh $STACK_NAME delete
aws sqs delete-queue \
--queue-url $QUEUE_URL

exit $RESULT
