#!/usr/bin/env bash

STACKNAME="iamauth"
REGION="us-east-1"
IAMUSER="mydbuser"
AURORAEP="$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --region $REGION | jq '.Stacks[].Outputs[] | select(.OutputKey=="AuroraClusterEndpoint")' | jq -r .OutputValue)"
DBNAME="$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --region $REGION | jq '.Stacks[].Outputs[] | select(.OutputKey=="AuroraDatabaseName")' | jq -r .OutputValue)"

# Make sure you have the right region for the token!!
TOKEN="$(aws rds generate-db-auth-token --hostname $AURORAEP --port 3306 --username $IAMUSER --region=$REGION)"

#set -x
mysql -h ${AURORAEP%%:*} -P 3306 --ssl-ca=~/Downloads/rds-ca-2015-root.pem \
--enable-cleartext-plugin --user=$IAMUSER --password=$TOKEN
#set +x