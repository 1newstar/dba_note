
1. 目的
2. 先分析根节点: 根节点只有一个root页
3. 再分析internal节点(内节点)
4. 分析叶子节点
5. 使用 innodb_space 来查看page_info表的索引结构、数据分配情况
6. 主键索引的叶子节点存储的所有行记录的计算公式	
7. 查看索引的统计信息
	

1. 目的

	根据分析出来的主键索引结构和数据页结构，画出B+Tree索引示意图
	了解数据在B+树中怎么分布的
	
	
2. 先分析根节点: 根节点只有一个root页

	基本信息

		提取关键信息来做分析。

		ROOT NODE #3: 2 records, 26 bytes
		
	shell> innodb_space -s ibdata1 -T test_db/page_info -p 3 page-records > root_3.log

	shell> cat root_3.log 
	Record 125: (id=1) → #7
	Record 138: (id=647473) → #38

	根节点所在的数据页编号为3，有两条记录即两个分支(2个内节点)。 就是说根节点扇出两个分支(2个内节点)。
	id=1的记录 指向编号为7的数据页
	id=647473的记录 指向编号为38的数据页

	根据信息得到如下 B+Tree图:
	root(level2)     
						page3	
	id				1       647473
		
	level1	
			   page7          page38
				 
	
3. 再分析internal节点(内节点)

	统计/分析 数据页编号 page no =7的数据			
		shell> innodb_space -s ibdata1 -T test_db/page_info -p 7 page-records > internal_7.log
	
		-- 统计:
			shell> wc -l internal_7.log 
			1128 internal_7.log
		
		-- 查看数据:
			shell> cat internal_7.log
			Record 125: (id=1) → #5    id=1 指向 page5
			Record 138: (id=575) → #6
			Record 151: (id=1149) → #8
			Record 164: (id=1723) → #9
			Record 177: (id=2297) → #10
			.................................
			Record 14750: (id=645751) → #1155
			Record 14763: (id=646325) → #1156
			Record 14776: (id=646899) → #1157  id=646899 指向 page1157
			
	
	统计/分析 数据页编号 page no=38的数据
		shell> innodb_space -s ibdata1 -T test_db/page_info -p 38 page-records > internal_38.log
		
		--统计:
			shell> wc -l internal_38.log 
			615 internal_38.log
			
		--查看数据:
			[root@mgr9 data]# cat internal_38.log
			Record 125: (id=647473) → #1158
			Record 138: (id=648047) → #1159
			Record 151: (id=648621) → #1160
			................................
			Record 8081: (id=998761) → #1768
			Record 8094: (id=999335) → #1769
			Record 8107: (id=999909) → #1770

	根据信息得到如下 B+Tree图:
	
		root(level2)     
							page3	
		id			      1     647473
		-------------------------------------------------
		level1	
				   page7          			page38
		id  	1.....646899            647473........999909
		-------------------------------------------------
		
		level0
			page5 <-...-> page1157     page1158 <-...-> page1770
			
			
	page7 有1128条记录(1128个分支);  
	page38 有615条记录(615个分支), 说明这个page3可以没有填满.

	internal节点/非叶子节点只存储主键的值、数据页编号、指向数据页的指针.
		
	非叶子页中保存是子页的页号。而且并不保存一个明确的KEY，而是保存一个Min Key，这个字段表示的是他们指向的子页的最小KEY：
		非叶子页 page7 保存的子页的页号为 page5， 其中 Min Key 为 1，指向子页编号为5的数据页。	
		非叶子页 page7 保存的子页的页号为 page6， 其中 Min Key 为 575，指向子页编号为6的数据页。	
		.....................................................................................
		

4. 分析叶子节点

	分析 叶子节点编号为5的数据页	
	
		shell> innodb_space -s ibdata1 -T test_db/page_info -p 5 page-records > lead_node_5.log

		shell> cat lead_node_5.log
		Record 125: (id=1) → (num=1)
		Record 151: (id=2) → (num=2)
		Record 177: (id=3) → (num=3)
		Record 177: (id=3) → (num=3)
		.........................................
		Record 14971: (id=572) → (num=572)
		Record 14997: (id=573) → (num=573)
		Record 15023: (id=574) → (num=574)

	分析 叶子节点编号为1157的数据页	
	
		shell> innodb_space -s ibdata1 -T test_db/page_info -p 1157 page-records > lead_node_1157.log
		
		shell> cat lead_node_1157.log
		Record 125: (id=646899) → (num=646899)
		Record 151: (id=646900) → (num=646900)
		Record 177: (id=646901) → (num=646901)
		.........................................
		Record 14971: (id=647470) → (num=647470)
		Record 14997: (id=647471) → (num=647471)
		Record 15023: (id=647472) → (num=647472)


	分析 叶子节点编号为1158的数据页	
	
		shell> innodb_space -s ibdata1 -T test_db/page_info -p 1158 page-records > lead_node_1158.log
		
		shell> cat lead_node_1158.log
		Record 125: (id=647473) → (num=647473)
		Record 151: (id=647474) → (num=647474)
		Record 177: (id=647475) → (num=647475)
		.........................................
		Record 14971: (id=648044) → (num=648044)
		Record 14997: (id=648045) → (num=648045)
		Record 15023: (id=648046) → (num=648046)


	分析 叶子节点编号为1770的数据页	
	
		shell> innodb_space -s ibdata1 -T test_db/page_info -p 1770 page-records > lead_node_1770.log

		shell> cat lead_node_1770.log
		Record 125: (id=999909) → (num=999909)
		Record 151: (id=999910) → (num=999910)
		Record 177: (id=999911) → (num=999911)
		.........................................
		Record 2439: (id=999998) → (num=999998)
		Record 2465: (id=999999) → (num=999999)
		Record 2491: (id=1000000) → (num=1000000)

	根据信息得到如下 B+Tree图:
		root(level2)     
								page3	
		id					1     		647473
		-------------------------------------------------
		level1	
					  page7          					page38
		min key  1.....646899           		647473........999909
				   page5
		-------------------------------------------------
		level0
				page5 <-...-> page1157        page1158 <-...-> page1770

		id:  1.....574   646899...647472   647473...648046   999909...1000000
		num: 1.....574   646899...647472   647473...648046   999909...1000000
			
			
		一个叶子节点页有574条记录.
		主键索引的叶子节点存储的是整行数据.
		叶子节点最后一个数据页有 92行记录, 说明这个数据页没有填满.


5. 使用 innodb_space 来查看page_info表的索引结构、数据分配情况

	shell> innodb_space -s ibdata1 -T test_db/page_info space-indexes
	id          name                            root        fseg        used        allocated   fill_factor 
	16561       PRIMARY                         3           internal    3           3           100.00%     
	16561       PRIMARY                         3           leaf        1743        2016        86.46%      
	16562       idx_num                         4           internal    1           1           100.00%     
	16562       idx_num                         4           leaf        832         992         83.87% 


6. 主键索引的叶子节点存储的所有行记录的计算公式

	叶子节点存储的所有行记录的计算公式:
	叶子节点使用了 1743个page;
	一个叶子节点页有 574条记录;
	叶子节点最后一个数据页有 92行记录;
	
	mysql> select 1742 * 574 + 92;
	+-----------------+
	| 1742 * 574 + 92 |
	+-----------------+
	|         1000000 |
	+-----------------+
	1 row in set (0.00 sec)

		
		
7. 查看索引的统计信息
	
	mysql> select * from mysql.innodb_index_stats  where table_name = 'page_info';
	+---------------+------------+------------+---------------------+--------------+------------+-------------+-----------------------------------+
	| database_name | table_name | index_name | last_update         | stat_name    | stat_value | sample_size | stat_description                  |
	+---------------+------------+------------+---------------------+--------------+------------+-------------+-----------------------------------+
	| base_db       | page_info  | PRIMARY    | 2020-07-31 10:51:26 | n_diff_pfx01 |     998739 |          20 | id                                |
	| base_db       | page_info  | PRIMARY    | 2020-07-31 10:51:26 | n_leaf_pages |       1743 |        NULL | Number of leaf pages in the index |
	| base_db       | page_info  | PRIMARY    | 2020-07-31 10:51:26 | size         |       2019 |        NULL | Number of pages in the index      |
	| base_db       | page_info  | idx_num    | 2020-07-31 10:51:26 | n_diff_pfx01 |    1000064 |          20 | num                               |
	| base_db       | page_info  | idx_num    | 2020-07-31 10:51:26 | n_diff_pfx02 |    1000064 |          20 | num,id                            |
	| base_db       | page_info  | idx_num    | 2020-07-31 10:51:26 | n_leaf_pages |        832 |        NULL | Number of leaf pages in the index |
	| base_db       | page_info  | idx_num    | 2020-07-31 10:51:26 | size         |        993 |        NULL | Number of pages in the index      |
	+---------------+------------+------------+---------------------+--------------+------------+-------------+-----------------------------------+
	7 rows in set (0.06 sec)


	主键索引: 
		stat_name=n_leaf_pages时：stat_value 表示叶子节点使用的数据页的数量为 1743个Page; 
		stat_name=size时：        stat_value 表示为叶子节点和非叶子节点分配的数据页的数量的 2019个Page; 
			参考: https://mp.weixin.qq.com/s/698g5lm9CWqbU0B_p0nLMw?  (MySQL统计信息简介 )

	
