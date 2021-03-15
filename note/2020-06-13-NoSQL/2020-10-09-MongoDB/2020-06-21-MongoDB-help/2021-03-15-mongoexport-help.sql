[root@localhost ~]# mongoexport --help
Usage:
  mongoexport <options>

Export data from MongoDB in CSV or JSON format.

See http://docs.mongodb.org/manual/reference/program/mongoexport/ for more information.

general options:
      --help                                      print usage
      --version                                   print the tool version and exit

verbosity options:
  -v, --verbose=<level>                           more detailed log output (include multiple times for more verbosity, e.g. -vvvvv, or specify a numeric value, e.g. --verbose=N)
      --quiet                                     hide all log output

connection options:
  -h, --host=<hostname>                           mongodb host to connect to (setname/host1,host2 for replica sets)
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

namespace options:
  -d, --db=<database-name>                        database to use
  -c, --collection=<collection-name>              collection to use

uri options:
      --uri=mongodb-uri                           mongodb uri connection string

output options:
  -f, --fields=<field>[,<field>]*                 comma separated list of field names (required for exporting CSV) e.g. -f "name,age"
      --fieldFile=<filename>                      file with field names - 1 per line
      --type=<type>                               the output format, either json or csv (defaults to 'json') (default: json)
  -o, --out=<filename>                            output file; if not specified, stdout is used
      --jsonArray                                 output to a JSON array rather than one object per line
      --pretty                                    output JSON formatted to be human-readable
      --noHeaderLine                              export CSV data without a list of field names at the first line
      --jsonFormat=<type>                         the extended JSON format to output, either canonical or relaxed (defaults to 'relaxed') (default: relaxed)

querying options:
  -q, --query=<json>                              query filter, as a JSON string, e.g., '{x:{$gt:1}}'
      --queryFile=<filename>                      path to a file containing a query filter (JSON)
  -k, --slaveOk                                   allow secondary reads if available (default true) (default: false)
      --readPreference=<string>|<json>            specify either a preference mode (e.g. 'nearest') or a preference json object (e.g. '{mode: "nearest", tagSets: [{a: "b"}], maxStalenessSeconds: 123}')
      --forceTableScan                            force a table scan (do not use $snapshot or hint _id). Deprecated since this is default behavior on WiredTiger
      --skip=<count>                              number of documents to skip
      --limit=<count>                             limit the number of documents to export
      --sort=<json>                               sort order, as a JSON string, e.g. '{x:1}'
      --assertExists                              if specified, export fails if the collection does not exist (default: false)
