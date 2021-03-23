
大纲
	0. 相关参数
	1. 初始化表结构和数据
	2. MySQL 5.7.22 (BNL算法)
		2.1 查看SQL的执行计划
		2.2 SQL的执行时间
	3. MySQL 8.0.18 (Hash Join)
		3.1 官方文档
		3.2 查看SQL的执行计划
		3.3 EXPLAIN ANALYZE
		3.4 SQL的执行时间
		3.5 思考	
	4. BNL算法和Hash Join的性能对比	
	5. MySQL 5.7.22 (NLJ算法)		
		5.1 查看SQL的执行计划
		5.2 SQL的执行时间
	6. 思考
		1. 有了Hash Join, 是否还需要NLJ算法
	7. 相关参考
	8. 小结
	
0. 相关参数
	
root@mysqldb 05:41:  [test_db]> show global variables like '%join_buffer%';
+------------------+---------+
| Variable_name    | Value   |
+------------------+---------+
| join_buffer_size | 4194304 |
+------------------+---------+
1 row in set (0.00 sec)



1. 初始化表结构和数据

	create table t1(id int primary key, a int, b int, index(a));
	create table t2 like t1;
	delimiter ;;
	create procedure idata()
	begin
	  declare i int;
	  set i=1;
	  while(i<=1000)do
		insert into t1 values(i, 1001-i, i);
		set i=i+1;
	  end while;
	  
	  set i=1;
	  while(i<=1000000)do
		insert into t2 values(i, i, i);
		set i=i+1;
	  end while;

	end;;
	delimiter ;
	call idata();
	

2. MySQL 5.7.22:
	mysql> select version();
	+------------+
	| version()  |
	+------------+
	| 5.7.22-log |
	+------------+
	1 row in set (0.00 sec)

	
2.1 查看SQL的执行计划
	mysql> explain  select * from t1 join t2 on (t1.b=t2.b) where t2.b>=1 and t2.b<=2000;
	+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+----------------------------------------------------+
	| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra                                              |
	+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+----------------------------------------------------+
	|  1 | SIMPLE      | t1    | NULL       | ALL  | NULL          | NULL | NULL    | NULL |   1000 |   100.00 | Using where                                        |
	|  1 | SIMPLE      | t2    | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 998222 |     1.11 | Using where; Using join buffer (Block Nested Loop) |
	+----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+----------------------------------------------------+
	2 rows in set, 1 warning (0.01 sec)

	
2.2 SQL的执行时间(MySQL 5.7.24不支持Hash Join):
	1000 rows in set (51.65 sec)
	
	
3. MySQL 8.0.18：
	mysql> select version();
	+-----------+
	| version() |
	+-----------+
	| 8.0.18    |
	+-----------+
	1 row in set (0.00 sec)
	
3.1 官方文档
	https://dev.mysql.com/doc/refman/8.0/en/hash-joins.html
	


3.2 查看SQL的执行计划：
	
	mysql> EXPLAIN FORMAT=TREE select * from t1 join t2 on (t1.b=t2.b) where t2.b>=1 and t2.b<=2000;
	
	+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| EXPLAIN                                                                                                                                                                                                                                                                 |
	+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| -> Inner hash join (t2.b = t1.b)  (cost=99911849.08 rows=11089138)
		-> Table scan on t2  (cost=90.65 rows=998222)
		-> Hash
			-> Filter: ((t1.b >= 1) and (t1.b <= 2000))  (cost=104.00 rows=1000)
				-> Table scan on t1  (cost=104.00 rows=1000)
	 |
	+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	1 row in set (0.00 sec)


3.3 EXPLAIN ANALYZE

	使用它可以估算成本、查看实际执行的统计数据，包括第一条记录的返回时间，全部记录返回时间，返回记录的数量以及循环数量。
	此外，EXPLAIN还将可以使用新的输出格式，树状输出。
	
	mysql> EXPLAIN ANALYZE select * from t1 join t2 on (t1.b=t2.b) where t2.b>=1 and t2.b<=2000;
	+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| EXPLAIN                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
	+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| -> Inner hash join (t2.b = t1.b)  (cost=99911831.70 rows=11089138) (actual time=3.092..491.775 rows=1000 loops=1)
		-> Table scan on t2  (cost=90.64 rows=998222) (actual time=0.048..274.177 rows=1000000 loops=1)
		-> Hash
			-> Filter: ((t1.b >= 1) and (t1.b <= 2000))  (cost=101.00 rows=1000) (actual time=0.072..2.101 rows=1000 loops=1)
				-> Table scan on t1  (cost=101.00 rows=1000) (actual time=0.067..0.975 rows=1000 loops=1)
	 |
	+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	1 row in set (0.49 sec)
	
	
3.4 SQL的执行时间:
	1000 rows in set (0.20 sec)
	

4. BNL算法和Hash Join的性能对比	
	
	BNL算法的执行时间:   1000 rows in set (51.65 sec)
	Hash Join的执行时间: 1000 rows in set (0.20 sec)
	NLJ算法的执行时间:   1000 rows in set (0.01 sec)

5. NLJ算法:
	
	alter table t2 add index idx_b(`b`);

	5.1 查看SQL的执行计划
		mysql> explain  select * from t1 join t2 on (t1.b=t2.b) where t2.b>=1 and t2.b<=2000;
		+----+-------------+-------+------------+------+---------------+-------+---------+--------------+------+----------+-------------+
		| id | select_type | table | partitions | type | possible_keys | key   | key_len | ref          | rows | filtered | Extra       |
		+----+-------------+-------+------------+------+---------------+-------+---------+--------------+------+----------+-------------+
		|  1 | SIMPLE      | t1    | NULL       | ALL  | NULL          | NULL  | NULL    | NULL         | 1000 |   100.00 | Using where |
		|  1 | SIMPLE      | t2    | NULL       | ref  | idx_b         | idx_b | 5       | test_db.t1.b |    1 |   100.00 | NULL        |
		+----+-------------+-------+------------+------+---------------+-------+---------+--------------+------+----------+-------------+
		2 rows in set, 1 warning (0.00 sec)
		
	5.2 SQL的执行时间:
		1000 rows in set (0.01 sec)


6. 思考
	1. 有了Hash Join, 是否还需要NLJ算法
	  答: 需要的. 通过对比可以发现NLJ算法的执行速度结对Hash Join的执行速度更快.
		  如果被驱动表是一个大表并且没有索引，那么会造成全表扫描，对磁盘I/O影响很大。
		  
	  
 
7. 相关参考
	
	https://mbd.baidu.com/newspage/data/landingsuper?context=%7B%22nid%22%3A%22news_10054537612828754509%22%7D&n_type=1&p_from=3 深入理解MySQL 8.0 hash join
	
		MySQL 8.0.18 版本增加了一个新的特性hash join，关于hash join，通常其执行过程如下：
			首先基于join操作的一个表，在内存中创建一个对应的hash表，然后再一行一行的读另外一张表，通过计算哈希值，查找内存中的哈希表。
	
	https://mp.weixin.qq.com/s/wnYeAtmFQtR_AsA7gnrGHw   MySQL8的 Hash Join
	 
	https://mp.weixin.qq.com/s/WDHqiJuhZVW6cSYSsUPlFA   MySQL8.0.18 试用Hash Join
	
	https://mp.weixin.qq.com/s/_0ImdUFMVZGTq-NoO9tHpw   MySQL8 的 Hash join 算法
	
	https://mp.weixin.qq.com/s/cS_1JgLm4UKlwWp4cXoc1A   MySQL 8.0之hash join
	
	https://mysqlserverteam.com/hash-join-in-mysql-8/
	
	
8. 小结
	NLJ算法，不需要全表扫描，查询性能在大多数场景下还是会比Hash join算法快的。


	
	
	

