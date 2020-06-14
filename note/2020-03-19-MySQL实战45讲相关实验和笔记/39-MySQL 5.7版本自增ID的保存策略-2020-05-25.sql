
1. 表结构和数据初始化
2. 删除 id=5 的记录


1. 表结构和数据初始化
	drop table if exists t;
	CREATE TABLE `t` (
	  `id` bigint(11) NOT NULL AUTO_INCREMENT,
	  `c` int(11) DEFAULT NULL,
	  `d` int(11) DEFAULT NULL,
	  PRIMARY KEY (`id`),
	  KEY `c` (`c`)
	) ENGINE=InnoDB  DEFAULT CHARSET=utf8mb4;
	
	DROP PROCEDURE IF EXISTS `idata`;
	DELIMITER ;;
	CREATE DEFINER=`root`@`%` PROCEDURE `idata`()
	begin
	  declare i int;
	  set i=1;
		start transaction;
	  while(i<=5) do
		INSERT INTO t (c,d) values (i,i);
		set i=i+1;
	  end while;
		commit;
	end
	;;
	DELIMITER ;

	call idata();
		
	
	
	root@mysqldb 20:58:  [test_db]> use db1;
	Database changed
	root@mysqldb 20:59:  [db1]> show create table t;
	+-------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| Table | Create Table                                                                                                                                                                                                         |
	+-------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| t     | CREATE TABLE `t` (
	  `id` bigint(11) NOT NULL AUTO_INCREMENT,
	  `c` int(11) DEFAULT NULL,
	  `d` int(11) DEFAULT NULL,
	  PRIMARY KEY (`id`),
	  KEY `c` (`c`)
	) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 |
	+-------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	1 row in set (0.00 sec)

	root@mysqldb 20:59:  [db1]> select * from t;
	+----+------+------+
	| id | c    | d    |
	+----+------+------+
	|  1 |    1 |    1 |
	|  2 |    2 |    2 |
	|  3 |    3 |    3 |
	|  4 |    4 |    4 |
	|  5 |    5 |    5 |
	+----+------+------+
	5 rows in set (0.00 sec)


2. 删除 id=5 的记录

	root@mysqldb 20:59:  [db1]> delete from t where id=5;
	Query OK, 1 row affected (0.01 sec)

	root@mysqldb 20:59:  [db1]> select * from t;
	+----+------+------+
	| id | c    | d    |
	+----+------+------+
	|  1 |    1 |    1 |
	|  2 |    2 |    2 |
	|  3 |    3 |    3 |
	|  4 |    4 |    4 |
	+----+------+------+
	4 rows in set (0.01 sec)

	root@mysqldb 20:59:  [db1]> show create table t;
	+-------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| Table | Create Table                                                                                                                                                                                                         |
	+-------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| t     | CREATE TABLE `t` (
	  `id` bigint(11) NOT NULL AUTO_INCREMENT,
	  `c` int(11) DEFAULT NULL,
	  `d` int(11) DEFAULT NULL,
	  PRIMARY KEY (`id`),
	  KEY `c` (`c`)
	) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 |
	+-------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	1 row in set (0.00 sec)
	
重启MySQL 
	[root@mgr9 ~]# /etc/init.d/mysql restart
	Shutting down MySQL.... SUCCESS! 
	Starting MySQL... SUCCESS! 


	root@mysqldb 21:02:  [db1]> show create table t;
	+-------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| Table | Create Table                                                                                                                                                                                                         |
	+-------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	| t     | CREATE TABLE `t` (
	  `id` bigint(11) NOT NULL AUTO_INCREMENT,
	  `c` int(11) DEFAULT NULL,
	  `d` int(11) DEFAULT NULL,
	  PRIMARY KEY (`id`),
	  KEY `c` (`c`)
	) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 |
	+-------+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
	1 row in set (0.05 sec)

	root@mysqldb 21:08:  [db1]> select max(id)+1 from t;
	+-----------+
	| max(id)+1 |
	+-----------+
	|         5 |
	+-----------+
	1 row in set (0.00 sec)

插入新的一行	
	root@mysqldb 21:02:  [db1]> INSERT INTO `t` (`c`, `d`) VALUES ('6', '6');  
	Query OK, 1 row affected (0.01 sec)

	root@mysqldb 21:03:  [db1]> select * from t;
	+----+------+------+
	| id | c    | d    |
	+----+------+------+
	|  1 |    1 |    1 |
	|  2 |    2 |    2 |
	|  3 |    3 |    3 |
	|  4 |    4 |    4 |
	|  5 |    6 |    6 |
	+----+------+------+
	5 rows in set (0.00 sec)

