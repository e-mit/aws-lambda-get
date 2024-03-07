#!/bin/bash

# Run this script with one of the following input arguments:
entryFuncs=("clean" "stack" "update_function" "update_layer")

ID_FILE_NAME="id.txt"

_make_names() {
    FUNCTION_NAME="testFunction$RAND_ID"
    STACK_NAME="testStack$RAND_ID"
    BUCKET_NAME="testbucket$RAND_ID" # Lower case only
    LAYER_NAME=$FUNCTION_NAME-layer
}

_get_id() {
    if [ ! -f $ID_FILE_NAME ]; then
        RAND_ID=$(dd if=/dev/random bs=8 count=1 2>/dev/null \
		          | od -An -tx1 | tr -d ' \t\n')
        echo $RAND_ID > $ID_FILE_NAME
        _make_names
        echo "Creating $STACK_NAME"
    else
        RAND_ID=$(cat $ID_FILE_NAME)
        _make_names
        echo "Found $STACK_NAME"
    fi
}

_delete_files() {
    rm -rf package function/__pycache__
    rm -f function/*.pyc out.yml *.zip
}

clean() {
    echo "Deleting the stack and its resources (lambda and role)"
    aws cloudformation delete-stack --stack-name $STACK_NAME

    # Note that the layer(s) are not included in the stack.
    echo "Delete layer (all versions)"
    while true; do
    VERSION=$(aws lambda list-layer-versions \
    --layer-name $LAYER_NAME | \
    python3 -c \
"import sys, json
try:
    print(json.load(sys.stdin)['LayerVersions'][0]['Version'])
except:
    exit(1)"
    )
    if [[ "$?" -ne 0 ]]; then
        break
    fi
    echo Deleting layer $LAYER_NAME:$VERSION
    aws lambda delete-layer-version \
    --layer-name $LAYER_NAME \
    --version-number $VERSION
    done

    echo "Delete the log group (was automatically created but is not in the stack)"
    aws logs delete-log-group --log-group-name /aws/lambda/$FUNCTION_NAME 2> /dev/null
    _delete_files
    rm -f $ID_FILE_NAME
}

_prepare_packages() {
    _delete_files
    pip3 install --target package/python -r requirements.txt &> /dev/null
}

stack() {
    echo Making temporary S3 bucket $BUCKET_NAME
    aws s3 mb s3://$BUCKET_NAME

    _prepare_packages

    aws cloudformation package \
    --template-file template.yml \
    --s3-bucket $BUCKET_NAME \
    --output-template-file out.yml &> /dev/null

    aws cloudformation deploy \
    --template-file out.yml \
    --stack-name $STACK_NAME \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides functionName=$FUNCTION_NAME

    echo Deleting the temporary S3 bucket
    aws s3 rb --force s3://$BUCKET_NAME

    echo Created Lambda $FUNCTION_NAME
}


update_function() {
    _delete_files
    cd function
    zip -r ../function.zip .
    cd ..
    aws lambda update-function-code \
    --function-name $FUNCTION_NAME \
    --zip-file fileb://function.zip &> /dev/null
}


update_layer() {
    _prepare_packages
    cd package
    zip -r ../package.zip . &> /dev/null
    cd ..
    LAYER_ARN=$(aws lambda publish-layer-version \
    --layer-name $LAYER_NAME \
    --description "Python package layer" \
    --zip-file fileb://package.zip \
    --compatible-runtimes python3.10 \
    --compatible-architectures "x86_64" | jq -r '.LayerVersionArn')

    aws lambda update-function-configuration \
    --function-name $FUNCTION_NAME \
    --layers $LAYER_ARN &> /dev/null

    echo "Created and assigned layer $LAYER_ARN"
}

################################################

ok=0
for i in "${entryFuncs[@]}"
do
    if [ "$i" == "$1" ]; then
        echo "Executing $i()"
        _get_id
        $i
        ok=1
    fi
done

if (( ok == 0 )); then
    echo "Error: command not recognised"
fi
