




子查询语法

	FROM子句
		SELECT m, n FROM (SELECT m2 + 1 AS m, n2 AS n FROM t2 WHERE m2 > 2) AS t;

		这个例子中的子查询是：(SELECT m2 + 1 AS m, n2 AS n FROM t2 WHERE m2 > 2)，很特别的地方是它出现在了FROM子句中。
		FROM子句里边儿不是存放我们要查询的表的名称么，这里放进来一个子查询是个什么鬼？
		其实这里我们可以把子查询的查询结果当作是一个表，子查询后边的 AS t 表明这个子查询的结果就相当于一个名称为t的表，这个名叫t的表的列就是子查询结果中的列
		比如例子中表t就有两个列：m列和n列。
		这个放在FROM子句中的子查询本质上相当于一个表，但又和我们平常使用的表有点儿不一样，设计MySQL的大叔把这种由子查询结果集组成的表称之为派生表。
	

IN子查询优化
	物化表的提出
		
		root@mysqldb 14:43:  [audit_db]> EXPLAIN SELECT * FROM t1 WHERE key1 IN (SELECT key3 FROM t2 WHERE common_field = '100');
		+----+--------------+-------------+------------+--------+---------------+------------+---------+------------------+-------+----------+-------------+
		| id | select_type  | table       | partitions | type   | possible_keys | key        | key_len | ref              | rows  | filtered | Extra       |
		+----+--------------+-------------+------------+--------+---------------+------------+---------+------------------+-------+----------+-------------+
		|  1 | SIMPLE       | t1          | NULL       | ALL    | idx_key1      | NULL       | NULL    | NULL             | 10212 |   100.00 | Using where |
		|  1 | SIMPLE       | <subquery2> | NULL       | eq_ref | <auto_key>    | <auto_key> | 403     | audit_db.t1.key1 |     1 |   100.00 | NULL        |
		|  2 | MATERIALIZED | t2          | NULL       | ALL    | idx_key3      | NULL       | NULL    | NULL             | 10210 |    10.00 | Using where |
		+----+--------------+-------------+------------+--------+---------------+------------+---------+------------------+-------+----------+-------------+
		3 rows in set, 1 warning (0.00 sec)
		
		root@mysqldb 14:43:  [audit_db]> show warnings;
		+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
		| Level | Code | Message                                                                                                                                                                                                                                                                                                                                                      |
		+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
		| Note  | 1003 | /* select#1 */ select `audit_db`.`t1`.`id` AS `id`,`audit_db`.`t1`.`key1` AS `key1`,`audit_db`.`t1`.`key2` AS `key2`,`audit_db`.`t1`.`key3` AS `key3`,`audit_db`.`t1`.`common_field` AS `common_field` from `audit_db`.`t1` semi join (`audit_db`.`t2`) where ((`<subquery2>`.`key3` = `audit_db`.`t1`.`key1`) and (`audit_db`.`t2`.`common_field` = '100')) |
		+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
		1 row in set (0.00 sec)
		
			SELECT
				`audit_db`.`t1`.`id` AS `id`,
				`audit_db`.`t1`.`key1` AS `key1`,
				`audit_db`.`t1`.`key2` AS `key2`,
				`audit_db`.`t1`.`key3` AS `key3`,
				`audit_db`.`t1`.`common_field` AS `common_field`
			FROM
				`audit_db`.`t1` semi JOIN (`audit_db`.`t2`)
			WHERE
			(
				(
					`<subquery2>`.`key3` = `audit_db`.`t1`.`key1`
				)
				AND (
					`audit_db`.`t2`.`common_field` = '100'
				)
			)
		
			Semi join: 
				使用哈希连接执行，将会利用子查询部分作为构建表，通过连接属性计算哈希值，然后使用外部查询的连接属性的哈希值进行匹配，输出匹配的结果。
				这里利用子查询构建 subquery2 表
				
		不直接将不相关子查询的结果集当作外层查询的参数，而是将该结果集写入一个临时表里。
		
		写入临时表的过程是这样的：

			该临时表的列就是子查询结果集中的列。

			写入临时表的记录会被去重。

			我们说IN语句是判断某个操作数在不在某个集合中，集合中的值重不重复对整个IN语句的结果并没有啥子关系，所以我们在将结果集写入临时表时对记录进行去重可以让临时表变得更小，更省地方～
			
			一般情况下子查询结果集不会大的离谱，所以会为它建立基于内存的使用Memory存储引擎的临时表，而且会为该表建立哈希索引。

			如果子查询的结果集非常大，超过了系统变量tmp_table_size或者max_heap_table_size，临时表会转而使用基于磁盘的存储引擎来保存结果集中的记录，索引类型也对应转变为B+树索引。
			
		设计MySQL的大叔把这个将子查询结果集中的记录保存到临时表的过程称之为物化（英文名：Materialize）
		为了方便起见，我们就把那个存储子查询结果集的临时表称之为物化表。
		正因为物化表中的记录都建立了索引（基于内存的物化表有哈希索引，基于磁盘的有B+树索引），通过索引执行IN语句判断某个操作数在不在子查询结果集中变得非常快，从而提升了子查询语句的性能。
		
		

			