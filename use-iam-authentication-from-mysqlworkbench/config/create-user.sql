CREATE USER mydbuser IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS';

GRANT ALL ON `%`.* TO mydbuser@`%`;
