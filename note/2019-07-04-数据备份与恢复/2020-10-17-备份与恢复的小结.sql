

1. 如果要做 binlog server， 那么在哪一台从库做备份，就做对应备份从库的 binlog server。
	-- GTID模式下不需要这样做，在从库做备份，可以根据主库来做 binlog server。
	
2. 基于全备加增量binlog的恢复，速度慢

3. 利用现有的延迟从库做数据恢复，速度更快

4. 以利用IO_Thread、SQL_thread来做各种数据的恢复操作。
 
5. GTID模式下，在从库做备份，可以用主库的binlog做数据恢复，从库可以不用开启binlog。 