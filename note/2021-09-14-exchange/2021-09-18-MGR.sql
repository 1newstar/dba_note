
优点：
	数据的强一致性。
	

缺点：
	1. 路由/驱动没有做好。
		-- 主库宕机，会自动完成新的组复制架构，但是应用连接还是连接到了宕机的主库上了。
		-- 需要中间件来实现。
	
	MongoDB 的驱动就做得很好。
	
	
	