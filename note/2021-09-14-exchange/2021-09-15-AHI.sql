
1. 作用

	加快查询操作的速度，适用于二级索引等值比较，例如=， <=>，in。
	
	
2. 工作机制
	InnoDB会自动监控到建立哈希索引能带来查询性能上的提升，则建立哈希索引。
	不需要人为干预，只需要控制是否开启AHI。
	
	
	