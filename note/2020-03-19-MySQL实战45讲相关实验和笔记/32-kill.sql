

MySQL 的两个 kill 命令：
 kill query thread_id: 表示终止这个线程中正在执行的语句；
 kill [connection] thread_id: 表示断开这个线程的连接，如果这个线程有语句正在执行，要先停止正在执行的语句。

 
 
create  database db1 DEFAULT CHARSET utf8mb4 -- UTF-8 Unicode COLLATE utf8mb4_general_ci;

use db1;
CREATE TABLE `t` (
  `id` INT(11) NOT NULL,
  `c` INT(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

INSERT INTO t VALUES (1,1);


session A             session B             		session C
begin;  
update t set c=c+1 where id=1;
				      update t set c=c+1 where id=1;
					  (Block)								
													
												    kill query 29;   
					  ERROR 1317 (70100): Query
					  execution was interrupted		


mysql> show processlist;
+----+----------+--------------------+------+---------+------+----------+-------------------------------+
| Id | User     | Host               | db   | Command | Time | State    | Info                          |
+----+----------+--------------------+------+---------+------+----------+-------------------------------+
| 28 | root     | 192.168.0.54:44308 | NULL | Query   |    0 | starting | show processlist              |
| 29 | root     | 192.168.0.54:44310 | db1  | Query   |    7 | updating | update t set c=c+1 where id=1 |
+----+----------+--------------------+------+---------+------+----------+-------------------------------+
7 rows in set (0.00 sec)

mysql> kill query 29;
Query OK, 0 rows affected (0.00 sec)

mysql> show processlist;
+----+----------+--------------------+------+---------+------+----------+------------------+
| Id | User     | Host               | db   | Command | Time | State    | Info             |
+----+----------+--------------------+------+---------+------+----------+------------------+
| 28 | root     | 192.168.0.54:44308 | NULL | Query   |    0 | starting | show processlist |
| 29 | root     | 192.168.0.54:44310 | db1  | Sleep   |   66 |          | NULL             |
+----+----------+--------------------+------+---------+------+----------+------------------+
7 rows in set (0.00 sec)





set global innodb_thread_concurrency=2; 

session A					session B					session C				session D		session E
SELECT SLEEP(100) FROM t;	SELECT SLEEP(100) FROM t;				
														SELECT * FROM t;
														(Blocked)		
																				show processlist;
																				(1st)
																				kill query 28;
																				(无效) 
																						
																				show processlist;
																				(2st)
																					
																								kill 28;
																							
														ERROR 2013 (HY000): Lost
														connection to MySQL server during query
														
														show processlist;
														(3st)
																											
1st:	
mysql> show processlist;
+----+----------+--------------------+------+---------+------+--------------+--------------------------+
| Id | User     | Host               | db   | Command | Time | State        | Info                     |
+----+----------+--------------------+------+---------+------+--------------+--------------------------+
| 27 | root     | 192.168.0.54:44306 | db1  | Query   |    0 | starting     | show processlist         |
| 28 | root     | 192.168.0.54:44308 | db1  | Query   |    6 | Sending data | SELECT * FROM t          |
| 29 | root     | 192.168.0.54:44310 | db1  | Query   |    8 | User sleep   | SELECT SLEEP(100) FROM t |
| 30 | root     | 192.168.0.54:44312 | db1  | Query   |   10 | User sleep   | SELECT SLEEP(100) FROM t |
+----+----------+--------------------+------+---------+------+--------------+--------------------------+
8 rows in set (0.00 sec)


2st: 
mysql> show processlist;
+----+----------+--------------------+------+---------+------+--------------+--------------------------+
| Id | User     | Host               | db   | Command | Time | State        | Info                     |
+----+----------+--------------------+------+---------+------+--------------+--------------------------+
| 27 | root     | 192.168.0.54:44306 | db1  | Query   |    0 | starting     | show processlist         |
| 28 | root     | 192.168.0.54:44308 | db1  | Query   |   31 | Sending data | SELECT * FROM t          |
| 29 | root     | 192.168.0.54:44310 | db1  | Query   |   33 | User sleep   | SELECT SLEEP(100) FROM t |
| 30 | root     | 192.168.0.54:44312 | db1  | Query   |   35 | User sleep   | SELECT SLEEP(100) FROM t |
+----+----------+--------------------+------+---------+------+--------------+--------------------------+
8 rows in set (0.00 sec)

3st: 
mysql> show processlist;
+----+----------+--------------------+------+---------+------+--------------+--------------------------+
| Id | User     | Host               | db   | Command | Time | State        | Info                     |
+----+----------+--------------------+------+---------+------+--------------+--------------------------+
| 27 | root     | 192.168.0.54:44306 | db1  | Query   |    0 | starting     | show processlist         |
| 28 | root     | 192.168.0.54:44308 | db1  | Killed  |   55 | Sending data | SELECT * FROM t          |
| 29 | root     | 192.168.0.54:44310 | db1  | Query   |   57 | User sleep   | SELECT SLEEP(100) FROM t |
| 30 | root     | 192.168.0.54:44312 | db1  | Query   |   59 | User sleep   | SELECT SLEEP(100) FROM t |
+----+----------+--------------------+------+---------+------+--------------+--------------------------+
9 rows in set (0.00 sec)



1. sesssion C 执行的时候被堵住了；但是 session D 执行的 kill query C 命令却没什么效果
	等行锁时，使用的是 pthread_cond_timedwait 函数，这个等待状态可以被唤醒。
	本例中, 28 号线程的等待逻辑为：
		每 10 毫秒判断一下是否可以进入 InnoDB 执行，如果不行，就调用 nanosleep 函数进入 sleep 状态。
	虽然 28 号线程的状态已经被设置成了 KILL_QUERY，但是在这个等待进入 InnoDB 的循环过程中
		并没有去判断线程的状态，因此根本不会进入终止逻辑阶段。
		
2. session E执行KILL CONNECTION，断开session C的连接，Command列变成了Killed
	把 28 号线程状态设置为 KILL_CONNECTION；
	关掉 28 号线程的网络连接; 因为有这个操作，所以会看到，这时候 session C 收到了断开连接的提示。
	
3. 执行show processlist的特别逻辑:
	如果一个线程的状态是 KILL_CONNECTION，就把 Command 列显示成 Killed。
	即使是客户端退出了，这个线程的状态仍然是在等待中。
	线程退出:
		只有等到满足进入 InnoDB 的条件后，session C 的查询语句继续执行
		然后才有可能判断到线程状态已经变成了 KILL_QUERY 或者 KILL_CONNECTION，再进入终止逻辑阶段。



kill命令无效的情况：
	1. 线程没有执行到判断线程状态的逻辑
		例如本文章的28号线程
		跟这种情况相同的，还有由于 IO 压力过大，读写 IO 的函数一直无法返回，导致不能及时判断线程的状态。
	
	2. 终止逻辑耗时较长
		从 show processlist 结果上看也是 Command=Killed，需要等到终止逻辑完成，语句才算真正完成。
		比较常见的场景有以下几种：
			1. 超大事务执行期间被 kill
			   这时候，回滚操作需要对事务执行期间生成的所有新数据版本做回收操作，耗时很长。		
			2. 大查询回滚
			   如果查询过程中生成了比较大的临时文件，加上此时文件系统压力大，删除临时文件可能需要等待 IO 资源，导致耗时较长。	
			3. DDL 命令执行到最后阶段，如果被 kill，需要删除中间过程的临时文件，也可能受 IO 资源影响耗时较久。
			   
	
Ctrl+C:
	在客户端执行 Ctrl+C, 不会直接终止线程;
	在客户端的操作只能操作到客户端的线程，客户端和服务端只能通过网络交互，是不可能直接操作服务端线程的。
	而由于 MySQL 是停等协议，所以这个线程执行的语句还没有返回的时候，再往这个连接里面继续发命令也是没有用的。
	
	Ctrl+C的逻辑:
	
		实际上，执行 Ctrl+C 的时候，是 MySQL 客户端另外启动一个连接，然后发送一个 kill query 命令
		要 kill 掉一个线程，还涉及到后端的很多操作
		因此, 在客户端执行完 Ctrl+C 并非万事大吉。

	
	
连接等待和-A参数:
	连接等待现象:
		db1这个库有很多张表, 每次用客户端连接都会卡在下面这个界面上
		Reading table information for completion of table and column names You can turn off this feature to get a quicker startup with -A
		如果db1 这个库里表很少的话，连接起来就会很快，可以很快进入输入命令的状态。
		
		
		客户端在连接成功后需要做的操作:
		1. 每个客户端在和服务端建立连接的时候，需要做的事情就是 TCP 握手、用户校验、获取权限。
			但这几个操作，跟库里面表的个数无关。
		
		2. 当使用默认参数连接的时候，客户端在连接成功后，需要多做一些操作实现一个本地库名和表名补全的功能
			1. 执行 show databases；
			2. 切到 db1 库，执行 show tables；
			3. 把这两个命令的结果用于构建一个本地的哈希表。
				最花时间的就是在本地构建哈希表的操作。
				所以，当一个库中的表个数非常多的时候，这一步就会花比较长的时间。	
			
		我们感知到的连接过程慢，其实并不是连接慢，也不是服务端慢，而是客户端慢。
	
	
	-A参数: 
		You can turn off this feature to get a quicker startup with -A
		如果在连接命令中加上 -A，就可以关掉这个自动补全的功能，然后客户端就可以快速返回了。

	
	
-quick参数:

–quick 参数的意思，是让客户端变得更快。	

MySQL 客户端发送请求后，接收服务端返回结果的方式有两种：
	1. 本地缓存，也就是在本地开一片内存，先把结果存起来
		MySQL 客户端默认使用本地缓存
		如果你用 API 开发，对应的就是 mysql_store_result 方法。
    2. 不缓存，读一个处理一个
		加上 –quick 参数，就会使用不缓存的方式
		如果你用 API 开发，对应的就是 mysql_use_result 方法。
		采用不缓存的方式时，如果本地处理得慢，就会导致服务端发送结果被阻塞，因此会让服务端变慢。
	
	
-quick参数的3个作用:
	跳过表名自动补全功能
	mysql_store_result 需要申请本地内存来缓存查询结果，如果查询结果太大，会耗费较多的本地内存，可能会影响客户端本地机器的性能；
	不会把执行命令记录到本地的命令历史文件。
	
	
show processlist.command='Killed'的解决办法:

	发现一个线程处于 Killed 状态，可以通过影响系统环境，让这个 Killed 状态尽快结束。
	比如，如果是 InnoDB 并发度的问题，你就可以临时调大 innodb_thread_concurrency 的值，或者停掉别的线程，让出位子给这个线程执行。
	
	而如果是回滚逻辑由于受到 IO 资源限制执行得比较慢，就通过减少系统压力让它加速。