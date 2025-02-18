
唯一索引和普通索引的区别：

	从查询的角度 
	
		普通索引 查找到第一个满足条件的记录后，继续向后遍历，直到第一个不满足条件的记录。
		
		唯一索引 由于索引定义了唯一性，查找到第一个满足条件的记录后，直接停止继续检索。


	
	RR隔离级别下加锁的角度：
	
		唯一索引会加行锁
		普通索引会加next-key锁
		
	change buffer的角度：
		唯一索引用不到change buffer优化
		普通索引可以用到change buffer优化。
		
		