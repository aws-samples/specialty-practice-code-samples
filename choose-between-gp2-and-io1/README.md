# Comparing gp2 with io1 for database workloads

## Project files
Below is a description of the files available in this project
### Create table (MySQL) *mysql-create-table.sql*
To create the objects for this test, the DDL is included in the file mysql-create-table.sql.
The script will need to be edited to replace <mydbuser> with your database username. <mydbuser> 
should reflect the DB Username used in the config file as this user will be inserting
and querying data from the test table.

The script creates a schema *myschema*, a table *mytesttable* with a variety of columns and 
then adds few indexes to simulate a realistic I/O workload. After the table is created, 
permissions for <mydbuser> are granted. Included with the file is
the DML to add one row to the table for validation.

### Database configuration *config/database-config.json*
Database connections and methods are configured for this project in a JSON file using 
the format below:

    {
     "ParameterKey": "AuthenticationType",
     "ParameterValue": "iam"
    }

The file is located in the config/ directory as database-config.json and contains the
following values for configuring the database connection information.
* AuthenticationType

  Possible Values 
      
      iam - for IAM authentication             
      db - for traditional database authentication                  
* DatabaseHost     
  
  Hostname or endpoint for the database       
* DatabasePort
  
  Port listening for database connections       
* DatabaseName 
  
  Name of the database to connect to       
* DatabaseUsername
  
  Name of the database user   
* DatabasePassword
  
  Password if using db authentication otherwise empty   
* SSLCertLocation
  
  Local location of the SSL certificate for the database 
  
*Note: To use the IAM authentication type, your database must already be configured with IAM
authentication*

### Running the mysql workload *submit_workload.py*
The python script *submit_workload.py*  collects two command line arguments.
The first is for the workload type (insert or query) and is used by the function *run_mysql(workload)* which 
executes a specified 100k times, writing to the output.log every 50 rows.
The second arguement is for the number of threads you would like to execute (integer)

#### run_mysql (workload)
Executes a workload (insert or query) 10k times against the database. 

The run_mysql program uses two supporting functions. 
##### parse_config ()
The first *parse_config()* reads the DB configuration file *config/database-config.json* to retrieve 
database connection information. (See the section Database configuration)

##### get_iam_mysql_token (host, port, user)
The second *get_iam_mysql_token(host, port, user)* will call IAM to obtain an IAM authentication token and return.
This second function will only be called if IAM authentication is to be used.
    
## Script usage example
    
    python submitworkload.py insert 250
    
command line argument expected values 
* insert 
* query
    
Purpose: To insert some data into mysql or query some data from mysql


