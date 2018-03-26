#!/usr/bin/env bash

function check_prereqs {
  if ! which mysql 2>&1 > /dev/null ; then
    echo "$0 error: Please install 'mysql'." > /dev/stderr
    exit 127
  fi
  if ! which jq 2>&1 > /dev/null ; then
    echo "$0 error: Please install 'jq'." > /dev/stderr
    exit 127
  fi
}

function create_stack {
    # create a Aurora MySQL cluster or an Amazon RDS MySQL database
    echo "Launching cloudformation stack with parameters from cf-parameters.json"
    aws cloudformation create-stack --stack-name "$STACKNAME" --template-body file://create-database.yaml \
        --parameters file://config/cf-parameters.json --region $REGION --capabilities CAPABILITY_IAM

    echo "Checking to see if the stack is up... waiting until complete..."
    aws cloudformation wait stack-create-complete --stack-name "$STACKNAME" --region $REGION
}

function create_user {
    export MASTERUSER="$(cat config/cf-parameters.json | jq '.[] | select(.ParameterKey=="DatabaseUsername")' | jq -r .ParameterValue)"
    export MASTERPASS="$(cat config/cf-parameters.json | jq '.[] | select(.ParameterKey=="DatabasePassword")' | jq -r .ParameterValue)"
    export DBNAME="$(cat config/cf-parameters.json | jq '.[] | select(.ParameterKey=="DatabaseName")' | jq -r .ParameterValue)"

    export AURORAEP="$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --region $REGION | jq '.Stacks[].Outputs[] | select(.OutputKey=="AuroraClusterEndpoint")' | jq -r .OutputValue)"
    export CLUSTERNAME="$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --region $REGION | jq '.Stacks[].Outputs[] | select(.OutputKey=="AuroraClusterName")' | jq -r .OutputValue)"
    export CLUSTEIDE="$(aws rds describe-db-clusters --region us-east-1 | jq --arg CN "$CLUSTERNAME" '.DBClusters[] | select(.DBClusterIdentifier==$CN)' | jq -r .DbClusterResourceId)"

    # Alter the instance to add IAM authentication
    echo "modifying the new Aurora MySQL Cluster to use IAM authentication"
    aws rds modify-db-cluster \
        --db-cluster-identifier $CLUSTERNAME \
        --apply-immediately \
        --enable-iam-database-authentication

    # Create a user (or use an existing IAM user), policy and attach the policy to the user
    echo "Creating IAM user and access policy"
    aws iam create-user --user-name $IAMUSER

    aws iam create-policy --policy-name database-login-$IAMUSER --policy-document "{\"Version\": \"2012-10-17\", \"Statement\": [{\"Action\": [\"rds-db:connect\"], \"Resource\": [\"arn:aws:rds-db:$REGION:$ACCOUNTID:dbuser:$CLUSTERID/$IAMUSER\"], \"Effect\": \"Allow\"}]}"

    aws iam attach-user-policy --policy-arn arn:aws:iam::$ACCOUNTID:policy/database-login-mydbuser --user-name $IAMUSER

    echo "Connect to the database and create the database user"
    mysql -h ${AURORAEP%%:*} -P 3306 --user=$MASTERUSER --password=$MASTERPASS < config/create-user.sql
}

function main {
  export ACCOUNTID="123456789012"
  export STACKNAME="iamauth"
  export REGION="us-east-1"
  export IAMUSER="mydbuser"
  set -x
  check_prereqs &&
  create_stack &&
  create_user
  set +x
}

main

