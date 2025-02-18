
0. InnoDB一条事务日志要经历的4个阶段
	创建日志阶段 对应 Log sequence number，记为LSN1
	日志刷盘阶段 对应 Log flushed up to，记为LSN2		
	脏页刷盘阶段 对应 Pages flushed up to，记为LSN3 
	检查点checkpoint阶段 对应 Last checkpoint at ，记为LSN4
	
1. 前置条件
	
	双1模式

2. 崩溃恢复的场景

	有 1-10 个事务已经写入 redo log buffer    			-- LSN1
										     
	目前已经 flush（刷新） 1-9 个 事务的redo日志到磁盘	-- LSN2							 
	目前已经 flush（刷新） 1-8 个 事务的脏页到磁盘 		-- LSN3
	
	此时 checkpoint 到 1-7 事务		 					-- LSN4
	
	
	
	如果这个时候发生 crash recovery

3. 崩溃恢复的流程
	
	那么在恢复的时候，1-7 的第7个事务事务作为崩溃的起点，然后顺序的扫描redo，大概过程如下：
	
		LSN3 - LSN4 = 表示崩溃恢复需要额外多跑的日志，因为 LSN3 的脏页已经刷盘，不需要应用小于 LSN3 的redo log进行恢复第8个事务。
			-- LSN也会写到 InnoDB的数据页中，用来确保数据页不会被多次执行重复的 redo log。
		
		
		LSN2 - LSN4 = 表示崩溃后实际要恢复的日志量, 也就是需要应用第9个事务的redo日志+对应磁盘上的数据页进行恢复出1个最新更新的数据页出来;
			-- 因为 redo 已经提交，所以可以应用redo恢复出1个最新更新的数据页出来，确保了数据的持久性。
			-- crash-safe的工作流程。
			
		第10个事务的处理会相对比较复杂：
		
			  1. 先判断 redo log的完整性
				  redo 有commit标识，直接提交事务，去更新内存数据页
				  redo 没有commit标识，但是有完整的prepare，需要判断binlog的完整性
				  
			  2. binlog的完整性
				  通过binlog_checksum参数验证binlog的完整性，如果binlog是完整的，就提交事务
				  否则，回滚事务。
	
	checkpoint在崩溃恢复中的作用：
	
		可以看到，只需要判断 第9和第10 这2个事务需要回滚 还是 刷盘， 在崩溃恢复的场景下大大缩短了恢复时间。
		
4. 小结
	1个案例，就把崩溃恢复涉及到的知识点(redo log、checkpoint、脏页、两阶段提交)串联起来了。


5. 相关参考
	
	《2021-09-09-checkpoint（检查点）技术》
	《15 ：崩溃恢复、crash-safe（崩溃安全）、两阶段提交》
	《2021-09-08-redo log的深入学习》
	
	
6. 问题
	
	6.1 checkpoint 和 flush 都可以把脏页刷新到磁盘，两者有什么关系？
	
		答：真正 脏页刷新到磁盘 的操作是 flush，flush 操作会记录 checkpoint 
	
			checkpoint 只是1个检查点标记，作用是减少崩溃恢复所需要的时间、推进释放redo log可以被覆盖的空间
			
			如果 redo 写满或者内存没有可用空闲空间(或者说脏页占比达到75%)，会强制 flush，然后记录 checkpoint.
			
			Pages flushed up to 是脏页已经到刷盘的LSN，checkpoint 之前的脏页都落盘了(注意：checkpoint LSN 不是脏页刷盘的最新LSN)，checkpoint 是用来做 推进释放redo 可以被覆盖的空间，这个步骤需要把对应的脏页进行刷盘。			

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	
Checkpoint 是一个lsn，这个lsn之前的Redo空间是Free部分，可以被覆盖了。recovery 时从这个lsn开始重做redo.

Lastest lsn 是所有脏页的最小lsn。这个lsn之前产生的脏页都已经持久化。

Current lsn是当前产生的最大lsn.

Modified Age是指所有脏页的Redo Log占用的空间，即Lastest lsn和Current lsn之间的部分。它是判断是否要使用同步刷脏的重要指标。

另外还有一个Checkpoint Age是Checkpoint到Current lsn的空间，即redo的使用空间。
Checkpoint Age和Modified Age差别不大。
状态信息中显示给用户的是Checkpoint Age.