
主键索引和普通索引的区别：

	从查询的角度：
		主键索引只要搜索ID这个B+Tree即可拿到数据。
		普通索引先搜索普通索引拿到主键值，再到主键索引树搜索一次(回表)
	
	从存储的角度：
		主键索引的叶子节点存储的是整行记录
		普通索引的叶子节点后面存储的是主键值
			
	
	