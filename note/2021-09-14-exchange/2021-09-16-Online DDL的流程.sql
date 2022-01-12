
1. 比如添加字段(rebuild 方式)的执行流程
2. 添加二级索引(no-rebuild 方式)的执行流程
3. 小结




1. 比如添加字段(rebuild 方式)的执行流程
	
	1. DDL prepare 阶段
	
		1. 对表加MDL写锁，阻塞读写请求。
			-- 避免数据不一致，阻塞DML和select请求。
			
		2. 然后创建2个文件 
			1. 生成临时日志文件，用于把增量操作记录在临时日志文件中
			2. 生成临时文件，用于把原表的数据拷贝到临时文件中
	
	2. DDL执行阶段
	
		1. MDL写锁降级为MDL读锁，允许读写请求。
			-- 避免1个表在执行DLL期间，其它DDL也可以执行
		
		2. 迁移原表的数据到临时文件中
		
		3. 原表的数据拷贝完成后，把临时日志文件的操作应用到临时日志文件中
		
	3. DDL commit 阶段
	
		1. MDL读锁升级为MDL写锁，再一次阻塞读写请求
			
			-- 避免数据不一致，阻塞DML和select请求。
		
		2. 再应用一次最后增量的DML
		
		3. 做数据表的转换操作，用临时文件替换原表的数据文件
		
		4. 释放MDL锁。

	4. 操作完成。
	
	
	重要的2个文件：临时文件、临时日志文件 

	除了加DML写锁阻塞业务的读写请求，其它操作都不会阻塞业务的读写请求。 
			
		1. 先应用增量的DML

		2. 再加MDL写锁

		3. 再应用一次最后增量的DML (1 - 2 这个步骤可能还有一小部分增量的DML)


		就类似于物理备份的过程，拷贝redo日志一样，加全局读锁后，此时阻塞写请求，redo 已经不可以写了，redo 可以获取到最新的。


	| 274408 | root  | localhost  | NULL | Query  |   54 | copy to tmp table  | alter table `abc_db`.`table_detail_log` change trade_return_data trade_return_data text |




2. 添加二级索引(no-rebuild 方式)的执行流程
	
	1. DDL prepare 阶段
		对表加MDL写锁，阻塞读写请求
		创建临时日志文件，用于把增量操作记录在临时日志文件中
		构建被创建的索引信息，创建索引的B+树.
		
		
	2. 构建索引树阶段
	
		1. MDL写锁降级为MDL读锁，允许读写请求。
		
		2. 遍历主键索引，对索引列进行归并排序；将排序好的数据，填充到索引树中
		
		3. 第2个步骤完成后，把临时日志文件的操作应用到索引树中
		
	
	3. DDL commit 阶段
	
		1. MDL读锁升级为MDL写锁，再一次阻塞读写请求
			
			-- 避免数据不一致，阻塞DML和select请求。
		
		2. 再应用一次最后增量的DML
		
		3. 释放MDL锁。
	
	-- 上面的流程，口述得不够好。
	-- 下面的可以做补充说明。
	
	有什么影响：
		
		1. 持有的MDL写锁，会短暂的阻塞业务的DML请求。
		2. 会导致主从延迟，不过这个延迟不会太大
		3. 扫描全表数据+生成一棵B+树的过程，会导致IO利用率高
		4. 当表上有慢查询或者DML长事务在执行，添加二级索引的操作会获取不到表的MDL写锁，同时会阻塞别的线程对表做DML请求。
		
		
	总的来说，还是要在业务低峰期执行。



3. 小结
	
	no-rebuild 和 rebuild 加的锁是一样的。
	
	
	
	
