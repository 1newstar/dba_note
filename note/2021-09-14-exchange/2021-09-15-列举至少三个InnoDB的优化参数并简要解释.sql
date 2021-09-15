
1. innodb_buffer_pool_size
	表示内部缓冲池的大小
	作用：
		1. 加速更新，当有一条记录需要更新的时候，InnoDB存储引擎就会先把记录写到redo，并更新内存，这时候更新就算完成了。
		2. 加速查询，直接访问内存就可以返回数据，性能高。
		
	设置太小：内存缓冲池不够用，SQL语句执行速度慢
	设置太大：内存溢出，数据库重启
	
2. sync_binlog
	binlog刷盘时机的参数，有3个值
	0：事务提交，写入到操作系统的页缓冲之后，binlog写入完成，操作系统崩溃，有丢失数据的风险
	1：事务提交，binlog需要持久化到磁盘
	大于1: 假设值为100，事务提交，写入到操作系统的页缓冲之后，binlog写入完成，等到累积100个事务之后，binlog需要持久化到磁盘
	
3. innodb_flush_log_at_trx_commit
	redo 刷盘时机的参数，有3个值
	0: 事务提交，redo 写入 redo log buffer 中，事务就算完成
	1: 事务提交，redo 需要刷盘，事务才算完成
	2: 事务提交，redo 写入操作系统的 page cache 中，事务就算完成
