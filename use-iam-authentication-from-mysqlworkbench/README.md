# IAM Authentication with SQL Workbench/J
Instructional scripts for connecting to an Aurora MySQL cluster with SQL Workbench/J using IAM authentication.

    http://www.sql-workbench.net/

## Prerequisites
IAM requires SSL connections between the client and the Amazon Aurora MySQL or Amazon RDS MySQL database.
The documentation about using SSL to encrypt  a connection to a DB instance is available online. 
    https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html 


* Download the Amazon RDS cert locally from the s3 bucket here
    https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem

### Create resources
Files below use CloudFormation to first create an Aurora database, 
enable IAM connections to the database.

1. Edit the values in config/cf-parameters.json for your environment
2. Edit the environment variables in the __main__ program in *create-stack-user.sh*
3. Edit the create-user.sql by replacing __mydbuser__ value with your database username.


    create-stack-user.sh
        create-database.yaml
           config/cf-parameters.json
           create-user.sql

### Connect scripts
Script to connect to the Aurora MySQL database with an IAM user using command line MySQL

1. Edit the environment variables at the top of the script with your Stack name, Region, and IAM user.
2. Execute the script from the command line.
    
    conn-aurora-iam-auth.sh

Script to connect to the Aurora MySQL database using SQL Workbench/J
1. Edit the environment variables at the top of the script with your Stack name, Region, and IAM user.
2. Execute the script from the command line.
    
    
    wbconn-aurora-iam-auth.sh

