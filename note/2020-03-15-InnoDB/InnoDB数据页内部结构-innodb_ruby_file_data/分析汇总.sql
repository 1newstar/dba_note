

100W行数据, 主键索引树高3层, 普通索引树高2层.

主键索引: 
	叶子节点存储的所有行记录的计算公式:
	叶子节点使用了 1743个page;
	一个叶子节点页有 574条记录;
	叶子节点最后一个数据页有 92行记录;
		1743*574=1000482
		574-92  = 482
		1000482-482=1000000条记录.

辅助索引:	
	叶子节点存储的所有行记录的计算公式:
	叶子节点使用了 832个page;
	一个叶子节点页有 1203条记录;
	叶子节点最后一个数据页有 307行记录;
		832*1203=1000896
		1203-307  = 896
		1000896-896=1000000条记录.
		
主键索引和辅助索引虽然在记录上是一致的, 但是索引树的高度却不一定是一致的.