
1. pt-table-sync
2. ԭ��
3. ע�����������������
4. ��زο�
5. ʵ��

1. pt-table-sync
	
	��Ч��ͬ��MySQL��֮������ݣ��������������˫��ͬ���ı����ݡ�
	������ͬ��������Ҳ����ͬ�������⡣����ͬ����ṹ�����������κ�����ģʽ�����������޸�һ����֮ǰ��Ҫ��֤���Ǳ���ڡ�

2. ԭ��
	
	1. �� checksums ���ҵ��������ݲ�һ�µ��б�

		SELECT db, tbl, CONCAT(db, '.', tbl) AS `table`, chunk, chunk_index, lower_boundary, upper_boundary, COALESCE(this_cnt-master_cnt, 0) AS cnt_diff, 
		COALESCE(this_crc <> master_crc OR ISNULL(master_crc) <> ISNULL(this_crc), 0) AS crc_diff, this_cnt, master_cnt, this_crc, master_crc 
		FROM consistency_db.checksums WHERE master_cnt <> this_cnt OR master_crc <> this_crc OR ISNULL(master_crc) <> ISNULL(this_crc)


	2. ȡ�����ID����СID���÷�Χ��ѯ����

		SELECT MIN(`id`), MAX(`id`) FROM `sbtest`.`t0` FORCE INDEX (`PRIMARY`) WHERE (((`id` >= '1')) AND ((`id` <= '1000')))

	3. ȡ�����ݲ�һ�µ�У��ֵ

		SELECT /*sbtest.t0:2/2*/ 1 AS chunk_num, COUNT(*) AS cnt, 
		COALESCE(LOWER(CONV(BIT_XOR(CAST(CRC32(CONCAT_WS('#', `id`, `r0`, `r1`, `r2`, `r3`, `r4`, `r5`, `r6`, `r7`, `r8`, `r9`, `r10`, CONCAT(ISNULL(`r0`), ISNULL(`r1`), ISNULL(`r2`), ISNULL(`r3`), ISNULL(`r4`), ISNULL(`r5`), ISNULL(`r6`), ISNULL(`r7`), ISNULL(`r8`), ISNULL(`r9`), ISNULL(`r10`)))) AS UNSIGNED)), 10, 16)), 0) AS crc 
		FROM `sbtest`.`t0` FORCE INDEX (`PRIMARY`) WHERE (`id` >= '1') AND ((((`id` >= '1')) AND ((`id` <= '1000')))) FOR UPDATE;
		+-----------+------+----------+
		| chunk_num | cnt  | crc      |
		+-----------+------+----------+
		|         1 | 1000 | e3896c7a |
		+-----------+------+----------+
		1 row in set (0.00 sec)

	4. ȡ�����ݲ�һ������chunk����������
		SELECT /*rows in chunk*/ `id`, `r0`, `r1`, `r2`, `r3`, `r4`, `r5`, `r6`, `r7`, `r8`, `r9`, `r10`, CRC32(CONCAT_WS('#', `id`, `r0`, `r1`, `r2`, `r3`, `r4`, `r5`, `r6`, `r7`, `r8`, `r9`, `r10`, CONCAT(ISNULL(`r0`), ISNULL(`r1`), ISNULL(`r2`), ISNULL(`r3`), ISNULL(`r4`), ISNULL(`r5`), ISNULL(`r6`), ISNULL(`r7`), ISNULL(`r8`), ISNULL(`r9`), ISNULL(`r10`)))) AS __crc 
		FROM `sbtest`.`t0` FORCE INDEX (`PRIMARY`) WHERE (`id` >= '1') AND (((`id` >= '1')) AND ((`id` <= '1000'))) ORDER BY `id` FOR UPDATE


	5. ȡ�����ݲ�һ�µ��м�¼
		SELECT `id`, `r0`, `r1`, `r2`, `r3`, `r4`, `r5`, `r6`, `r7`, `r8`, `r9`, `r10` FROM `sbtest`.`t0` WHERE `id`='1' LIMIT 1
		

	6. С��
		1. ֻ��Ҫ���������ݲ�һ�µļ�¼���ڵ�chunk�ļ�¼���м���������Ҫɨ��ȫ������ݡ�
		
	

3. ע�����������������

	1. ��û��Ψһ����
		Can not make changes on the master because no unique index exists at /usr/bin/pt-table-sync line 10857. while doing niuniu_db.t2 on 39.108.17.15
		--���� pt-table-sync --print ���ܴ�ӡҪ�޸������ݡ�
		mysql> show create table t2\G;
		*************************** 1. row ***************************
			   Table: t2
		Create Table: CREATE TABLE `t2` (
		  `id` int(11) NOT NULL,
		  `a` int(11) DEFAULT NULL,
		  `b` int(11) DEFAULT NULL,
		  KEY `a` (`a`)
		) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
		1 row in set (0.00 sec)
		
		
	2. �����������Կ���Դ�룬������Ŵ����������Դ���п�����

		shell > perl -MDBD:mysql
		
		
4. ��زο�

	https://www.cnblogs.com/gomysql/p/3662264.html 


5. ʵ��

	�ο��ʼǣ���2021-07-20-ʵ��.sql��

alter user 'pt_user'@'%' identified by '%123456Abc';

