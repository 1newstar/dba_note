ysql> show slave status\G;
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event     # 从库的 IO 线程的状态
                  Master_Host: 192.168.1.10
                  Master_User: repl_user
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000238
          Read_Master_Log_Pos: 190533643
               Relay_Log_File: db-b-relay-bin.000005
                Relay_Log_Pos: 190533856
        Relay_Master_Log_File: mysql-bin.000238
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 190533643
              Relay_Log_Space: 190534149
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1
                  Master_UUID: 7664fad8-49fd-11e8-a546-4201c0a8010a
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates    # 从库的 SQL 线程的状态
           Master_Retry_Count: 86400 
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 7664fad8-49fd-11e8-a546-4201c0a8010a:13797-700502
            Executed_Gtid_Set: 7664fad8-49fd-11e8-a546-4201c0a8010a:1-700502,
90e79fc1-49fd-11e8-a6dd-4201c0a8010b:1-17308
                Auto_Position: 1
         Replicate_Rewrite_DB: 
                 Channel_Name: 
           Master_TLS_Version: 
1 row in set (0.00 sec)

ERROR: 
No query specified

mysql> 
