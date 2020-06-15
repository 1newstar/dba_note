
mongotop -h 192.168.0.31 -u admin -p admin --authenticationDatabase=admin


[root@env30 journal]# mongotop --help
Usage:
  mongotop <options> <polling interval in seconds>

Monitor basic usage statistics for each collection.

See http://docs.mongodb.org/manual/reference/program/mongotop/ for more information.

general options:
      --help                                      print usage
      --version                                   print the tool version and exit

verbosity options:
  -v, --verbose=<level>                           more detailed log output (include multiple times for more verbosity, e.g. -vvvvv, or specify a numeric value, e.g. --verbose=N)
      --quiet                                     hide all log output

connection options:
  -h, --host=<hostname>                           mongodb host(s) to connect to (use commas to delimit hosts)
      --port=<port>                               server port (can also use --host hostname:port)

ssl options:
      --ssl                                       connect to a mongod or mongos that has ssl enabled
      --sslCAFile=<filename>                      the .pem file containing the root certificate chain from the certificate authority
      --sslPEMKeyFile=<filename>                  the .pem file containing the certificate and key
      --sslPEMKeyPassword=<password>              the password to decrypt the sslPEMKeyFile, if necessary
      --sslCRLFile=<filename>                     the .pem file containing the certificate revocation list
      --sslAllowInvalidCertificates               bypass the validation for server certificates
      --sslAllowInvalidHostnames                  bypass the validation for server name
      --sslFIPSMode                               use FIPS mode of the installed openssl library

authentication options:
  -u, --username=<username>                       username for authentication
  -p, --password=<password>                       password for authentication
      --authenticationDatabase=<database-name>    database that holds the user's credentials
      --authenticationMechanism=<mechanism>       authentication mechanism to use

kerberos options:
      --gssapiServiceName=<service-name>          service name to use when authenticating using GSSAPI/Kerberos (default: mongodb)
      --gssapiHostName=<host-name>                hostname to use when authenticating using GSSAPI/Kerberos (default: <remote server's address>)

uri options:
      --uri=mongodb-uri                           mongodb uri connection string

output options:
      --locks                                     report on use of per-database locks
  -n, --rowcount=<count>                          number of stats lines to print (0 for indefinite)
      --json                                      format output as JSON