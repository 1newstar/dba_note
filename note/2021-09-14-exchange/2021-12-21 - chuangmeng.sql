
2021-12-21: 3面 - 问得挺深


1. 幻读举例说明
	
	
2. 5.6 VS 5.7 新特性
	不够全。
	
3. 判断主从延迟的方案
	
	下面的描述不够自信
	Master_Log_File 和 Read_Master_Log_Pos，表示的是读到的主库的最新位点；Relay_Master_Log_File 和 Exec_Master_Log_Pos，表示的是备库执行的最新位点。


4. 怎么处理过期读问题
	我的回答：这方面没有经验。
	
	--补充：一致性要求高的可以不做读写分离，报表类的查询可以走从库查询。
	
	这些方案包括：
		强制走主库方案；
		sleep 方案；
		判断主备无延迟方案；
		配合 semi-sync 方案；
		等主库位点方案；
		等 GTID 方案。
		
5. pt-osc 中死锁是怎样的
	-- 只说了是 自增锁阻塞、主键索引记录锁阻塞 导致的死锁，面试官想要更详细的。
	
	
6. update 或者 delete 语句导致死锁的场景

	感觉这个问得不是很详细
	
	--补充：加锁是1个个加的，所以会导致死锁
	
		-- update语句，二级索引作为条件，先对二级索引的记录加锁再回到主键索引记录上加锁。
	
7. 什么情况下索引会失效
	1. 扫描的记录数超过总表的30%左右
	2. in 里面的值太多
	3. where 条件的索引字段做了函数操作
	4. 发生了隐式类型转换
	5. 发生了隐式字符编码转换
	
	
	
	
有什么要想问的： 
	
	-- 补充：刚才有些回答得不够好，回去了会继续复习下。要是在现场有纸和笔，通过画事务流程图，会方便描述好多。


	
多开口，更自信，学会做补充(比如描述不好、没有描述完整的情况下)。