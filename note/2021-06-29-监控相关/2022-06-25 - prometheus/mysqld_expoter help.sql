[root@iZbp1co0b2dkojjkbk7r8cZ ~]# /usr/local/mysqld_exporter/mysqld_exporter --help
usage: mysqld_exporter [<flags>]

Flags:
  -h, --help                   Show context-sensitive help (also try --help-long and --help-man).
      --exporter.lock_wait_timeout=2  
                               Set a lock_wait_timeout (in seconds) on the connection to avoid long metadata locking.
      --exporter.log_slow_filter  
                               Add a log_slow_filter to avoid slow query logging of scrapes. NOTE: Not supported by Oracle MySQL.
      --collect.heartbeat.database="heartbeat"  
                               Database from where to collect heartbeat data
      --collect.heartbeat.table="heartbeat"  
                               Table from where to collect heartbeat data
      --collect.heartbeat.utc  Use UTC for timestamps of the current server (`pt-heartbeat` is called with `--utc`)
      --collect.info_schema.processlist.min_time=0  
                               Minimum time a thread must be in each state to be counted
      --collect.info_schema.processlist.processes_by_user  
                               Enable collecting the number of processes by user
      --collect.info_schema.processlist.processes_by_host  
                               Enable collecting the number of processes by host
      --collect.info_schema.tables.databases="*"  
                               The list of databases to collect table stats for, or '*' for all
      --collect.mysql.user.privileges  
                               Enable collecting user privileges from mysql.user
      --collect.perf_schema.eventsstatements.limit=250  
                               Limit the number of events statements digests by response time
      --collect.perf_schema.eventsstatements.timelimit=86400  
                               Limit how old the 'last_seen' events statements can be, in seconds
      --collect.perf_schema.eventsstatements.digest_text_limit=120  
                               Maximum length of the normalized statement text
      --collect.perf_schema.file_instances.filter=".*"  
                               RegEx file_name filter for performance_schema.file_summary_by_instance
      --collect.perf_schema.file_instances.remove_prefix="/var/lib/mysql/"  
                               Remove path prefix in performance_schema.file_summary_by_instance
      --collect.perf_schema.memory_events.remove_prefix="memory/"  
                               Remove instrument prefix in performance_schema.memory_summary_global_by_event_name
      --web.config.file=""     [EXPERIMENTAL] Path to configuration file that can enable TLS or authentication.
      --web.listen-address=":9104"  
                               Address to listen on for web interface and telemetry.
      --web.telemetry-path="/metrics"  
                               Path under which to expose metrics.
      --timeout-offset=0.25    Offset to subtract from timeout in seconds.
      --config.my-cnf="/root/.my.cnf"  
                               Path to .my.cnf file to read MySQL credentials from.
      --tls.insecure-skip-verify  
                               Ignore certificate and server verification when using a tls connection.
      --collect.info_schema.innodb_tablespaces  
                               Collect metrics from information_schema.innodb_sys_tablespaces
      --collect.info_schema.innodb_metrics  
                               Collect metrics from information_schema.innodb_metrics
      --collect.global_status  Collect from SHOW GLOBAL STATUS
      --collect.global_variables  
                               Collect from SHOW GLOBAL VARIABLES
      --collect.slave_status   Collect from SHOW SLAVE STATUS
      --collect.info_schema.processlist  
                               Collect current thread state counts from the information_schema.processlist
      --collect.mysql.user     Collect data from mysql.user
      --collect.info_schema.tables  
                               Collect metrics from information_schema.tables
      --collect.perf_schema.eventsstatementssum  
                               Collect metrics of grand sums from performance_schema.events_statements_summary_by_digest
      --collect.perf_schema.eventswaits  
                               Collect metrics from performance_schema.events_waits_summary_global_by_event_name
      --collect.auto_increment.columns  
                               Collect auto_increment columns and max values from information_schema
      --collect.binlog_size    Collect the current size of all registered binlog files
      --collect.perf_schema.tableiowaits  
                               Collect metrics from performance_schema.table_io_waits_summary_by_table
      --collect.perf_schema.indexiowaits  
                               Collect metrics from performance_schema.table_io_waits_summary_by_index_usage
      --collect.perf_schema.tablelocks  
                               Collect metrics from performance_schema.table_lock_waits_summary_by_table
      --collect.perf_schema.eventsstatements  
                               Collect metrics from performance_schema.events_statements_summary_by_digest
      --collect.info_schema.userstats  
                               If running with userstat=1, set to true to collect user statistics
      --collect.info_schema.clientstats  
                               If running with userstat=1, set to true to collect client statistics
      --collect.perf_schema.file_events  
                               Collect metrics from performance_schema.file_summary_by_event_name
      --collect.perf_schema.file_instances  
                               Collect metrics from performance_schema.file_summary_by_instance
      --collect.perf_schema.memory_events  
                               Collect metrics from performance_schema.memory_summary_global_by_event_name
      --collect.perf_schema.replication_group_members  
                               Collect metrics from performance_schema.replication_group_members
      --collect.perf_schema.replication_group_member_stats  
                               Collect metrics from performance_schema.replication_group_member_stats
      --collect.perf_schema.replication_applier_status_by_worker  
                               Collect metrics from performance_schema.replication_applier_status_by_worker
      --collect.engine_innodb_status  
                               Collect from SHOW ENGINE INNODB STATUS
      --collect.heartbeat      Collect from heartbeat
      --collect.info_schema.tablestats  
                               If running with userstat=1, set to true to collect table statistics
      --collect.info_schema.schemastats  
                               If running with userstat=1, set to true to collect schema statistics
      --collect.info_schema.innodb_cmp  
                               Collect metrics from information_schema.innodb_cmp
      --collect.info_schema.innodb_cmpmem  
                               Collect metrics from information_schema.innodb_cmpmem
      --collect.info_schema.query_response_time  
                               Collect query response time distribution if query_response_time_stats is ON.
      --collect.engine_tokudb_status  
                               Collect from SHOW ENGINE TOKUDB STATUS
      --collect.slave_hosts    Scrape information from 'SHOW SLAVE HOSTS'
      --collect.info_schema.replica_host  
                               Collect metrics from information_schema.replica_host_status
      --log.level=info         Only log messages with the given severity or above. One of: [debug, info, warn, error]
      --log.format=logfmt      Output format of log messages. One of: [logfmt, json]
      --version                Show application version.
