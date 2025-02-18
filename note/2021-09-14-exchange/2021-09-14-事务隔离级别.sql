

0. 四种事务隔离级别

	如果没有事务控制，那么并发读写数据库会存在下面的问题：
		
		脏读：		读取到了事务未提交的记录
		
		不可重复读：事务内执行多次相同的查询，得不到一样的结果
		
		幻读：		针对insert，事务内的执行2次相同的查询，第2次查询得到的行数比第1次查询得到的行数多
					《2021-11-22 - 幻读的实验.sql》
	
	
	为了解决  脏读、不可重复读、幻读这些隐患， 就有了 事务隔离级别 的概念：

		读未提交（read uncommitted）、读提交（read committed）、可重复读（repeatable read）和串行化（serializable ）。
		 
		读未提交：是指 一个事务还没提交时，它做的变更就能被别的事务看到;
					允许脏读
					
		读已提交：是指 一个事务提交之后，它做的变更才会被其他事务看到;
					消除了脏读，允许不可重复读、幻读
					
		可重复读：是指 事务内执行多次相同的查询，得到的结果都是一样的;  (事务内相同的多次查询，读取到的结果都是一样的。)
					消除了脏读和幻读，实现了可重复读
					
		串行化：   是指 对于同一行记录，写会加写锁，读会加读锁。当出现读写锁冲突的时候，后访问的事务必须等前一个事务执行完成，才能继续执行。



2. RC和RR不一样的地方 
	
	2.0 
		消除了脏读，允许不可重复读、幻读
		消除了脏读和幻读，实现了可重复读
		
		
	2.1 创建视图快照的时机不一样
		
		在可重复读隔离级别下，只需要在事务开始的时候创建一致性视图，之后事务里的其他查询都共用这个一致性视图(事务内相同的2次查询，后一次查询可以复用前一次查询创建的一致性快照)；  -- 因此支持可重复读
		在读提交隔离级别下，每一个语句执行前都会重新算出一个新的视图。											 -- 因此不支持可重复读



	2.2 加锁方面的不一样
		
		语句的加锁：
			1. 
				insert into select 语句的加锁

				update join 关联更新语句的加锁

					RR/RC事务隔离级别下，驱动表的数据都是加写锁； 
					
					RC事务隔离级别下，关联到的被驱动表的数据不加锁；
					RR事务隔离级别下，关联到的被驱动表的数据加读锁；
					
						跟 insert into select 语句一样，RC事务隔离级别下， select 的语句不加锁; RR事务隔离级别下，select 的语句加读锁。
						
			2. 读已提交事务隔离级别下的一个优化：
				
				全表扫描: 语句执行过程中加上的行锁，在语句执行完成后，就要把 不满足条件的行 上的行锁直接释放了，不需要等到事务提交。
				普通索引的范围等值查询, 需要访问到不满足条件的第一个值为止, 并且需要加锁, 语句结束不会把不满足条件的锁释放掉.
				主键索引的范围等值查询, 也是需要访问到不满足条件的第一个值为止, 并且需要加锁, 语句执行结束，如果该记录不符合查询条件，会释放掉这条记录的锁.
					
			
			3. 加锁的基本单位：
				
				RC 为行锁。          						     -- 因此会有幻读。
				RR 为next-key锁，先加 gap lock, 再加 行锁。		 -- 因此消除了幻读。	
				RC 也会存在gap lock， 只发生在：
					唯一约束检查到有唯一冲突的时候，会加 S Next-key Lock，即对记录以及与和上一条记录之间的间隙加共享锁。

			


