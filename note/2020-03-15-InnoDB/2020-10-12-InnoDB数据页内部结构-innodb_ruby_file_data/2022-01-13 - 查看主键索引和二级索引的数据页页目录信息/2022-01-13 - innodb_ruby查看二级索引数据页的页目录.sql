

1. 初始化表结构和数据
	drop table if exists page_info3;
	CREATE TABLE `page_info3` (
			  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
			  `num` int(11) NOT NULL,
			  PRIMARY KEY (`id`),
			  KEY `idx_num` (`num`)
			) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4;
			-- 创建存储过程
	DROP PROCEDURE IF EXISTS insertbatch;
	CREATE PROCEDURE insertbatch()
	BEGIN
	DECLARE i INT;
	  SET i=1;
	  WHILE(i<=1000) DO
		INSERT INTO test_db.page_info3(num)VALUES(i);
		SET i=i+1; 
	  END WHILE;
	END;

	-- 调用存储过程
	call insertbatch();


2. 通过 space-index-pages-summary 得到整个索引树的概要信息

 
	shell> innodb_space -s ibdata1 -T test_db/page_info3 space-index-pages-summary 
	page        index   level   data    free    records 
	3           35152   1       26      16226   2       
	4           35153   0       13000   2754    1000    
	5           35152   0       14924   1044    574     
	6           35152   0       11076   4966    426     
	7           35153   0       13000   2754    1000    
	8           0       0       0       16384   0
	
	
3. 通过 page-directory-summary 分析页编号为7的数据页得到存储页目录的内容

	shell> innodb_space -s ibdata1 -T test_db/page_info3 -p 7 page-directory-summary
	slot    offset  type          owned   max key
	0       99      infimum       1       
	1       164     conventional  4       (num=4)
	2       216     conventional  4       (num=8)
	3       268     conventional  4       (num=12)
	4       320     conventional  4       (num=16)
	..............................................
	248     13008   conventional  4       (num=992)
	249     13060   conventional  4       (num=996)
	250     112     supremum      5       

	
	slot：槽编号 为 0-250; 槽的数量 251 个
    offset ：行记录的相对位置
    type：infimum、conventional、supremum
            
            
	owned：一个槽指针指向所在分组的行记录数量
		infimum： 1
		conventional： 4
		supremum： 5
		
    max key：
        每个槽指针指向所在分组中行记录的最大值
		
    slot: 1, owned=4， max key: num=4
	
		slot: 1 		表示槽的编号为1
		owned=4 		表示编号为1的槽拥有4行记录
		max key: num=4  表示编号为1的槽的最大记录为 num=4.
		
		
				
		
		
		
		
		
  