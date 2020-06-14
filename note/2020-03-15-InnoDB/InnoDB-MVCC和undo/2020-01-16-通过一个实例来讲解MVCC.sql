

### 这里可以用 markdown 格式来写

1. 基本概念
2. 可见性判断规则
3. 事务执行流程
4. 通过人肉分析可见性规则
5. 通过结论分析可见性规则
6. 小结
7. 相关参考					   


1. 基本概念
	read view是一致性视图, 它的实现逻辑是: InnoDB 为每个事务构造了一个数组，用来保存这个事务启动瞬间，当前正在 活跃 的所有事务 ID
	活跃的定义: 已经启动但是没有提交的事务
	
	低水位和高水位：
        低水位: 数组里面事务 ID 的最小值记为低水位  对应  m_up_limit_id  
        高水位: 当前系统里面已经创建过的事务ID 的最大值加 1 记为高水位  对应 m_low_limit_id
		
	read view 由 视图数组和高水位 组成 对应  m_ids 
	
	
2. 可见性判断规则

	数据版本的可见性规则，就是基于数据的 DATA_TRX_ID （行记录的事务ID） 和这个一致性视图里面的活跃事务ID对比结果得到的， 如下：
	 1. 一个数据版本， 对于一个事务视图来说， 除了自己的更新总是可见 即 当记录的 DATA_TRX_ID 和 事务创建者的 TRX_ID 一样，记录可见；         # 理解
	 2. m_ids: 
			有两种情况：
				1. 在活跃事务列表中，说明未提交，不可见；  # 理解      
				2. 不在活跃事务列表中， 在 m_ids 范围内， 表示这个版本是已经提交了的事务生成的，可见。
	 3. m_up_limit_id: 当记录的 DATA_TRX_ID 小于 read view 中的 m_up_limit_id, 说明 是在视图创建之前已经提交, 可见 # 理解
	 4. m_low_limit_id : 大于此值的都是未开启的事务， 不可见 # 理解
		
	
3. 事务执行流程
	例如下面中记录存在三个版本，在Repeatable-Read下select * from t1 查询返回的是第一个老的版本(1,1,'a')。	

		session A            session B                              备注
							 insert into t1 values(1,1,'a');        T1: row trx_id=1;
		begin;
		select * from t1;                                           S1时刻: 结果: (1,1,'a')

							 update t1 set c3='b' where id=1;       T2: row trx_id=3
							 
		select * from t1;                                           S2时刻: 结果: (1,1,'a')

							 update t1 set c3='c' where id=1;       T3: row trx_id=5

		select * from t1;									        S3时刻: 结果: (1,1,'a')
		


4. 通过人肉分析可见性规则
	
	4.1. 事务 A 此时的视图数组:
		1.1. 事务 A 开始前, 系统里面没有活跃事务, 即 m_ids 为 NULL
		1.2. 事务 B 的版本号: S1 = 2, S2 = 4, S3 = 5; 
		1.3. 事务 A 的版本号: T1 = 1, T2 = 3, T3 = 5;
		1.4. read view:
			事务 A 的 S1时刻: [2, 2]  这里只有一个高水位即 m_low_limit_id = 1+1 = 2, 由于数组里面只有一个事务即事务ID=1, 所以低水位即高水位.
			事务 A 的 S2时刻: [2, 2]  使用的是 S1时刻 的视图
			事务 A 的 S3时刻: [2, 2]  同样使用的是 S1时刻 的视图
		
		
	4.2. 画出跟事务A查询逻辑有关的操作:
	
		事务A 				事务B
							T1 时刻              历史版本: row trx_id=1, (1,1,'a')
											
		S1 时刻	
		[2, 2]
							T2 时刻              历史版本: row trx_id=3, (1,1,'b') 							
											 
		S2 时刻 
		[2, 2]
							T3 时刻              当前版本: row trx_id=5, (1,1,'c')
		S3 时刻             
		[2, 2]
		
	
	4.3. 事务 A 的S3时刻的查询结果为 (1,1,'a') 分析
		1. 事务B:
			T2 时刻, 把数据从  (1,1,'a') 改为了 (1,1,'b') , 这个数据的最新版本为 row trx_id = 3, 而 row trx_id=1 成了历史版本;
			T3 时刻, 把数据从  (1,1,'b') 改为了 (1,1,'c') , 这个数据的最新版本为 row trx_id = 5, 而 row trx_id=3 成了历史版本;
		
		2. 事务 A 的S3时刻的查询结果为 (1,1,'a') 分析:
			
			S3 时刻的视图数组是 [2, 2], 读数据都是从当前版本读起的
			因此, 找到最新的记录 (1,1,'c'), 判断 row trx_id = 5 比高水位(m_low_limit_id=2)大, 不可见
			然后通过 roll_ptr 构建上一个历史版本(1,1,'b'),  判断 row trx_id = 3 比高水位(m_low_limit_id=2)大, 不可见
			再往前找, 通过 rool_ptr 构建出 (1,1,'a'), 它的 row trx_id = 1, 比低水位(m_up_limit_id=2)小, 可见.
			所以最后返回(1,1,’a’)
		
		
	4.4. 构建行的多版本回溯查找数据: 
		
		update 是原地更新的, 所以 undo 存储的是 键值和老值, 所以 undo 不需要存储 c2 的值.
		
		1. insert into t1 values(1,1,'a');
				
			RowID   DB_TRX_ID   DB_ROLL_PTR   c1    c3
			1       1           NULL          1     'a'
			
			
		2. update t1 set c3='b' where id=1;; 

			当前最新版本的行数据:
				RowID   DB_TRX_ID   DB_ROLL_PTR   c1    c3
				1       3           2         	  1     'b'	

			undo log(旧版本的数据): 
				RowID   DB_TRX_ID   DB_ROLL_PTR   c1    c3
				1       1           NULL          1     'a'	
			
		3. update t1 set c3='c' where id=1; 

			当前最新版本的行数据:
				T3:
					RowID   DB_TRX_ID   DB_ROLL_PTR   c1     c3        
					1       5           3        	   1     'c'	

			undo log(旧版本的数据): 
				T2:
					RowID   DB_TRX_ID   DB_ROLL_PTR   c1     c3
					1       3           1         	   1     'b'
				T1:	
					RowID   DB_TRX_ID   DB_ROLL_PTR   c1     c3
					1       1           NULL           1     'a'	
			
		4. 在cluster index中，最新的版本记录为 T3(1,5,roll_ptr,1,'c') 其中5为事务id，数据就在page中；  # 理解了
			上一个版本为 T2(1,3,roll_ptr,1,'b'), 可通过 T3(1,5,roll_ptr,1,'c') 上 roll_ptr 指向的undo记录构造出来；
			而最老的版本为 T1(1,1,roll_ptr,1,'a'), 可通过 T2(1,3,roll_ptr,1,'b') 上 roll_ptr 指向的undo记录构造出来。
	
	4.5. 结论: 
		1. 如果当前最新的数据版本不可见, 会根据 DB_ROLL_PTR 构建并回溯查询历史版本,  直到找到对应可见的版本; 
		2. RR 隔离级别的 read view 是事务开始之后的第一个 SQL 申请，之后事务内的其他 SQL 都使用该 read view。
		3. 通过 分析实验结果的过程 来验证原理.
		
5. 通过结论分析可见性规则
		
	
	1. 一个数据版本， 对于一个事务视图来说， 除了自己的更新总是可见以外， 有三种情况：
		1. 版本未提交， 不可见；
		2. 版本已提交：
			2.1：是在视图创建之后提交的，不可见；
			2.2：是在视图创建之前提交的，可见。					   
	2. 这个规则对 RR和RC隔离级别都生效。
		
	3. 事务 A 的S3时刻 的返回结果分析:

		在 S1 阶段 是正式启动一个事务, 并且创建 read view; 
		虽然 T3 和 T2 的版本已经提交, 但是是在  视图创建之后提交的，所以不可见.
		T1 版本 在 视图创建之前提交, 符合 2.1, 所以可见
	

6. 小结：	
	6.1 MVCC实现原理
		1、通过 read view 判断行记录是否可见	
		2、读数据都是从当前版本开始读取的, 如果当前版本不可见, 通过 undo 构建历史版本, 通过 DB_ROLL_PTR 回溯查找数据历史版本, 直到找到对应可见的版本.
		
	6.2 MVCC(Mutil-Version Concurrency Control):	
		基本概念
			同一行记录在系统中可以存在多个版本，由此带来的并发控制 , 这就是数据库的多版本并发控制（MVCC）。
			基于 read view 也就是一致性视图 和 回滚段的 undo 信息实现。
		详细概念：
			InnoDB多版本数据是通过delete mark（删除标记）的行数据和回滚段中的undo信息组成的。
			
		
		MVCC 由 read view + 行的历史版本构成, 行的历史版本包括 delete mark(打了删除标记)的行记录和回滚段中的undo信息, 由此带来的并发控制, 被称为多版本并发控制.
	
		cluster index的历史版本在 undo日志 中或为 delete mark 的记录(没毛病, 理解了)，secondary index的历史版本是delete mark的记录。
	
		Undo记录中存储的是老版本数据，当一个旧的事务需要读取数据时，为了能读取到老版本的数据，需要顺着undo链找到满足其可见性的记录。
		当版本链很长时，通常可以认为这是个比较耗时的操作.

	
		undo log是真实存在的, 但是用于构建MVCC的行记录的多版本并不是物理上真实存在的，而是每次需要的时候根据当前版本和 undo log 计算出来的。   # 这里需要确认.
	
		


7. 相关参考					   
	https://mp.weixin.qq.com/s/UxawgHGembMKK2lA33ZQDA     InnoDB MVCC 详解
		学习人家是怎么分析的.
		之后 根据 MySQL 实战45讲的第8节, 看看是如何构建旧版本的.
			
	https://mp.weixin.qq.com/s/UxawgHGembMKK2lA33ZQDA     InnoDB MVCC 详解
	https://mp.weixin.qq.com/s/R3yuitWpHHGWxsUcE0qIRQ     InnoDB并发如此高，原因竟然在这？



