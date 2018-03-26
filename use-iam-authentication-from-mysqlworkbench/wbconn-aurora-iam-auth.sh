#!/usr/bin/env bash
#
#   Script to launch SQL Workbench from a command line and connect to
#   an Aurora MySQL database cluster using IAM authentication
#
STACKNAME="iamauth"
REGION="us-east-1"
IAMUSER="mydbuser"
AURORAEP="$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --region $REGION | jq '.Stacks[].Outputs[] | select(.OutputKey=="AuroraClusterEndpoint")' | jq -r .OutputValue)"
DBNAME="$(aws cloudformation describe-stacks --stack-name "$STACKNAME" --region $REGION | jq '.Stacks[].Outputs[] | select(.OutputKey=="AuroraDatabaseName")' | jq -r .OutputValue)"

# Make sure you have the right region for the token!!
TOKEN="$(aws rds generate-db-auth-token --hostname $AURORAEP --port 3306 --username $IAMUSER --region=$REGION)"

#set -x
java -jar ~/workbench/sqlworkbench.jar \
    -url=jdbc:mysql://$AURORAEP:3306/$DBNAME?verifyServerCertificate=false\&useSSL=true\&requireSSL=true \
    -driver=com.mysql.jdbc.Driver \
    -username=$IAMUSER \
    -password=$TOKEN \
    -libdir= /Users/wendyneu/workbench \
    -driverjar=/Users/wendyneu/workbench/mysql-connector-java-5.1.45-bin.jar
#set +x
