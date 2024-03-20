# Example parameters for creating an instance of this stack.
# Source this script, then run setup.sh

# Name of the stack to create (and the name prefix for all resources to be created):
STACK_NAME=teststack1

# Time period for the lambda repetition:
CYCLE_PERIOD_VALUE=1
CYCLE_PERIOD_UNIT=minute

# Name of the existing SQS queue for output:
QUEUE_NAME="test2Function5407c6-queue"

# Lambda timeout:
LAMBDA_TIMEOUT_SEC=10

# Parameters for the GET function:
LOG_LEVEL='DEBUG'
GET_URL="https://api.carbonintensity.org.uk/intensity"
GET_TIMEOUT_SEC=5
