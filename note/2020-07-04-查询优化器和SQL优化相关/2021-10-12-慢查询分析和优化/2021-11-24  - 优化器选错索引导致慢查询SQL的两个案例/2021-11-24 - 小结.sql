

1. SQL查询语句有 where 条件 + group by ，where 条件列有索引、group by 列也有索引, 这时候
	使用 group by 索引列 能够避免使用临时表分组，即使扫描的行数比where条件使用到的索引扫描行数多，优化器也会优先选择 group by列的索引。
	

2. 遇到1个案例
	
	
