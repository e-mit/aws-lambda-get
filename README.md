# AWS Lambda GET

![local tests](https://github.com/e-mit/aws-lambda-get/actions/workflows/tests.yml/badge.svg)
![cloud tests](https://github.com/e-mit/aws-lambda-get/actions/workflows/cloud-tests.yml/badge.svg)
![coverage](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/e-mit/9df92671b4e2859b1e75cf762121b73f/raw/aws-lambda-get.json)
![flake8](https://github.com/e-mit/aws-lambda-get/actions/workflows/flake8.yml/badge.svg)
![mypy](https://github.com/e-mit/aws-lambda-get/actions/workflows/mypy.yml/badge.svg)
![pycodestyle](https://github.com/e-mit/aws-lambda-get/actions/workflows/pycodestyle.yml/badge.svg)
![pydocstyle](https://github.com/e-mit/aws-lambda-get/actions/workflows/pydocstyle.yml/badge.svg)
![pylint](https://github.com/e-mit/aws-lambda-get/actions/workflows/pylint.yml/badge.svg)
![pyright](https://github.com/e-mit/aws-lambda-get/actions/workflows/pyright.yml/badge.svg)
![bandit](https://github.com/e-mit/aws-lambda-get/actions/workflows/bandit.yml/badge.svg)

Creates an AWS Lambda function which GETs json data from an HTTP endpoint, on a repeating periodic schedule, and puts the data into an AWS SQS queue.

This project configures AWS using the CLI with a CloudFormation/SAM template. The SQS queue must already exist.


### See also

- [github.com/e-mit/aws-lambda-db](https://github.com/e-mit/aws-lambda-db) creates an AWS Lambda function which receives data from a AWS SQS queue and stores it in an SQL database.
- [github.com/e-mit/aws-create-db](https://github.com/e-mit/aws-create-db) creates and configures an AWS Relational Database Service (RDS) instance running PostgreSQL.
- [github.com/e-mit/aws-ec2-grafana](https://github.com/e-mit/aws-ec2-grafana) for configuring and deploying Grafana on an EC2 instance to display a public data dashboard


### Readme Contents

- **[Testing](#testing)**<br>
- **[Deployment](#deployment)**<br>
- **[Development](#development)**<br>
- **[To do](#to-do)**<br>


## Testing

Tests and linting checks run via GitHub actions after each push. Tests can be run locally (no interaction with AWS), or with AWS (cloud tests).


### Local tests

Run all tests and linting with ```local-tests.sh```


### Cloud tests

These require AWS CLI authentication. Run with ```cloud-tests.sh```


## Deployment

1. Provide values for the environment variables listed in ```example_config.sh```
2. Execute script ```setup.sh```. This will create the resources and start the lambda.
3. Optional: change log level using: ```./stack.sh <stack name> loglevel <log level string e.g. DEBUG>```
4. Stop the lambda and delete all resources using: ```./stack.sh <stack name> delete```


## Development

After deploying the stack, the lambda code and the packaged Python library dependencies can be updated independently, and rapidly, using the following commands:

- Lambda function update: ```./stack.sh <stack name> update_function```
- Python packages update: ```./stack.sh <stack name> update_layer```


## To do

- Optional headers to send with the request
- Optional body data to send with the request
- Optional cookie data to send with the request
- Support API authentication
