
比如添加字段

1. 对表加MDL写锁
	-- 避免数据不一致
	
2. MDL写锁降级为MDL读锁
	-- 避免1个表在执行DLL期间，其它DDL也可以执行
	
3. 生成临时文件，把原表的数据拷贝到临时文件中
4. 生成临时日志文件，增量操作记录在临时日志文件中
5. 原表的数据拷贝完成，做2个操作：
	把临时日志文件的操作应用到临时日志文件中
	做数据表的转换操作，用临时文件替换原表的数据文件
	
6. MDL读锁升级为MDL写锁
7. 释放MDL锁。


重要的2个文件：临时文件、临时日志文件 



| 274408 | root  | localhost  | NULL | Query  |   54 | copy to tmp table  | alter table `abc_db`.`table_detail_log` change trade_return_data trade_return_data text |


