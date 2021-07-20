mysql> select * from sys.processlist;
+--------+---------+---------------------------------+------+---------+--------------+--------+-------------------------------+-------------------+----------+--------------+---------------+-----------+---------------+------------+-----------------+-----------+----------------+------------------------+----------------+-----------+-------------------+--------+-------------+-----------+----------------+------+--------------+
| thd_id | conn_id | user                            | db   | command | state        | time   | current_statement             | statement_latency | progress | lock_latency | rows_examined | rows_sent | rows_affected | tmp_tables | tmp_disk_tables | full_scan | last_statement | last_statement_latency | current_memory | last_wait | last_wait_latency | source | trx_latency | trx_state | trx_autocommit | pid  | program_name |
+--------+---------+---------------------------------+------+---------+--------------+--------+-------------------------------+-------------------+----------+--------------+---------------+-----------+---------------+------------+-----------------+-----------+----------------+------------------------+----------------+-----------+-------------------+--------+-------------+-----------+----------------+------+--------------+
|      1 |    NULL | sql/main                        | NULL | NULL    | NULL         | 455804 | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     34 |       1 | sql/compress_gtid_table         | NULL | Daemon  | Suspending   | 455804 | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     49 |      16 | root@localhost                  | sys  | Query   | Sending data |      0 | select * from sys.processlist | 797.37 us         |     NULL | 489.00 us    |             0 |         0 |             0 |          4 |               1 | YES       | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | 1713 | mysql        |
|      2 |    NULL | sql/thread_timer_notifier       | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|      3 |    NULL | innodb/io_ibuf_thread           | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|      4 |    NULL | innodb/io_log_thread            | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|      5 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|      6 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|      7 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|      8 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|      9 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     10 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     11 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     12 |    NULL | innodb/io_read_thread           | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     13 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     14 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     15 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     16 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     17 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     18 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     19 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     20 |    NULL | innodb/io_write_thread          | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     21 |    NULL | innodb/page_cleaner_thread      | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     23 |    NULL | innodb/srv_lock_timeout_thread  | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     24 |    NULL | innodb/srv_monitor_thread       | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     25 |    NULL | innodb/srv_error_monitor_thread | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     26 |    NULL | innodb/srv_master_thread        | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     27 |    NULL | innodb/srv_worker_thread        | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     28 |    NULL | innodb/srv_purge_thread         | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     29 |    NULL | innodb/srv_worker_thread        | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     30 |    NULL | innodb/srv_worker_thread        | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     31 |    NULL | innodb/buf_dump_thread          | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     32 |    NULL | innodb/dict_stats_thread        | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
|     33 |    NULL | sql/signal_handler              | NULL | NULL    | NULL         |   NULL | NULL                          | NULL              |     NULL | NULL         |          NULL |      NULL |          NULL |       NULL |            NULL | NO        | NULL           | NULL                   | 0 bytes        | NULL      | NULL              | NULL   | NULL        | NULL      | NULL           | NULL | NULL         |
+--------+---------+---------------------------------+------+---------+--------------+--------+-------------------------------+-------------------+----------+--------------+---------------+-----------+---------------+------------+-----------------+-----------+----------------+------------------------+----------------+-----------+-------------------+--------+-------------+-----------+----------------+------+--------------+
34 rows in set (0.06 sec)

