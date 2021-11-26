

1. 可以分别从读、写、存储空间的角度进行分析

2. 首先
	InnoDB存储引擎使用的是B+树作为底层的数据结构
	
3. 从写入的角度
	基于自增主键的顺序写，性能高，不会涉及到数据页的分裂和合并
	
4. 从读取的角度分析
	主键索引的叶子节点存储的是整行记录，根据主键来查找记录不需要回表，性能高

5. 从存储空间的角度进行分析
	主键长度越小，二级索引的叶子节点就越小，占用的磁盘空间就越少
		
6. 从复制的角度
	导致主从延迟的原因之一，表没有主键索引或者唯一索引
	
7. 从生态的角度分析
	使用pt工具包，都会要求表要有主键，比如 pt-osc、pt-table-checksum等
	