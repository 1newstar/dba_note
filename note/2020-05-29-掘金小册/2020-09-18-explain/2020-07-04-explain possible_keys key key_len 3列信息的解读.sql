
1. possible_keys
2. key
3. key_len

1. possible_keys

	可能用到的索引
	
2. key
	
	实际使用到的索引
	
	注意事项 
		possible_keys列中的值并不是越多越好，可能使用的索引越多，查询优化器计算查询成本时就得花费更长时间，所以如果可以的话，尽量删除那些用不到的索引。
		
		在使用index访问方法来查询某个表时，possible_keys列是空的，而key列展示的是实际使用到的索引, 如下所示:
			
			KEY idx_key_part(key_part1, key_part2, key_part3)
			
			mysql> EXPLAIN SELECT key_part2 FROM s1 WHERE key_part3 = 'a';
			+----+-------------+-------+------------+-------+---------------+--------------+---------+------+------+----------+--------------------------+
			| id | select_type | table | partitions | type  | possible_keys | key          | key_len | ref  | rows | filtered | Extra                    |
			+----+-------------+-------+------------+-------+---------------+--------------+---------+------+------+----------+--------------------------+
			|  1 | SIMPLE      | s1    | NULL       | index | NULL          | idx_key_part | 909     | NULL | 9688 |    10.00 | Using where; Using index |
			+----+-------------+-------+------------+-------+---------------+--------------+---------+------+------+----------+--------------------------+
			1 row in set, 1 warning (0.00 sec)
		
3. key_len

	key_len列表示当优化器决定使用某个索引执行查询时，该索引记录的最大长度，它是由这三个部分构成的：

		1. 对于使用固定长度类型的索引列来说，它实际占用的存储空间的最大长度就是该固定值，对于指定字符集的变长类型的索引列来说，比如某个索引列的类型是VARCHAR(100)，使用的字符集是utf8，那么该列实际占用的最大存储空间就是100 × 3 = 300个字节。

		2. 如果该索引列可以存储NULL值，则key_len比不可以存储NULL值时多1个字节。

		3. 对于变长字段来说，都会有2个字节的空间来存储该变长列的实际长度。
		
	EXPLAIN执行计划中有一列 key_len 用于表示本次查询中，所选择的索引长度有多少字节，通常我们可借此判断联合索引有多少列被选择了。
	在这里 key_len 大小的计算规则是：
	
		一般地，key_len 等于索引列类型字节长度，例如int类型为4-bytes，bigint为8-bytes；
		如果是字符串类型，还需要同时考虑字符集因素，例如：CHAR(30) UTF8则key_len至少是90-bytes；
			若该列类型定义时允许NULL，其key_len还需要再加 1-bytes；
			若该列类型为变长类型，例如 VARCHAR（TEXT\BLOB不允许整列创建索引，如果创建部分索引，也被视为动态列类型），其key_len还需要再加 2-bytes;
			
	注意事项:
		执行计划的生成是在MySQL server层中的功能，并不是针对具体某个存储引擎的功能，
		设计MySQL的大叔在执行计划中输出key_len列主要是为了让我们区分某个使用联合索引的查询具体用了几个索引列，而不是为了准确的说明针对某个具体存储引擎存储变长字段的实际长度占用的空间到底是占用1个字节还是2个字节。
		
	参考笔记：
		《2020-07-04-explains_utf8mb4字符集下各种数据类型占用的字节长度.sql》 
		《2020-07-04-explains_utf8字符集下各种数据类型占用的字节长度.sql》
	