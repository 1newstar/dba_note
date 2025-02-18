
1. 环境
2. 安装步骤
	2.1 两台物理机器信任机制建立
	2.2 MySQL 安装和配置主从结构
	2.3 安装MHA Node
	2.4 安装MHA Manager	
3. 配置MHA
4. 创建相关脚本
5. 	查看/etc/masterha 目录下的所有文件
6. 在主节点初始化VIP
7. 配置文件测试
8. 	MHA的启动和关闭	
9. 绑定VIP


1. 环境 

hostname    主机          端口号  通信端口号(server-id)    server_uuid                              MySQL版本      role      mha-node               
mha01		192.168.0.101  3306   3306101				   1b9bc372-0042-11ea-b8fa-0800274617cc     MySQL 8.0.18   Master                           
mha02       192.168.0.102  3306   3306102                  e588e3eb-0042-11ea-a95b-0800275dde84     MySQL 8.0.18   Slave     Mha manager & slave    
mha03       192.168.0.103  3306   3306103                  cbe6921b-0043-11ea-b484-0800270d5e94     MySQL 8.0.18   Slave     
VIP         192.168.0.104
mha-version: 0.58


传统复制基于Row+Position，GTID复制基于Row+Gtid搭建的一主两从复制结构：mha01->{mha02、mha03}


2. 安装步骤

2.1. 两台物理机器信任机制建立
	在 192.168.0.101 使用 ssh-keygen 生成 key:
		shell> ssh-keygen # 之后一路回车就行了。最后会在~/.ssh 下面产生： id_rsa id_rsa.pub 两个文件。
	生成信任文件：
		shell> cd ~/.ssh/
		shell> cat id_rsa.pub >authorized_keys
		shell> chmod 600 *
	
	
	保留.ssh 下面只有 id_rsa, id_rsa.pub 其它的文件可以删或是备份移走。
	shell> cd ~
	shell> scp –r .ssh 192.168.0.102:~/
	
		id_rsa                                                                                                    100% 1679   171.2KB/s   00:00    
		id_rsa.pub                                                                                                100%  392    73.6KB/s   00:00    
		authorized_keys                                                                                           100%  392   870.2KB/s   00:00    
		known_hosts                                                                                               100%  175   169.3KB/s   00:00 

	shell> scp –r .ssh 192.168.0.103:~/
		id_rsa                                                                                                    100% 1679   154.6KB/s   00:00    
		id_rsa.pub                                                                                                100%  392    43.9KB/s   00:00    
		authorized_keys                                                                                           100%  392   383.8KB/s   00:00    
		known_hosts                                                                                               100%  350   277.7KB/s   00:00 
		
	192.168.0.102
		shell> cd ~/.ssh/
		shell> chmod 600 *
		
	192.168.0.103
		shell> cd ~/.ssh/
		shell> chmod 600 *

2.2 MySQL 安装和配置主从结构
	
	master 授权
		reset master;     # 两台都是新的实例, 数据一致, 但是GTID不一致, 可以先在主库执行 reset master, 清空 GTID信息和binlog信息.
		create user mharpl@'192.168.0.%' identified by '123456abc';
		grant replication slave on *.* to mharpl@'192.168.0.%';
		ALTER USER 'mharpl'@'192.168.0.%' IDENTIFIED BY '123456abc' PASSWORD EXPIRE NEVER; #修改加密规则 
		ALTER USER 'mharpl'@'192.168.0.%' IDENTIFIED WITH mysql_native_password BY '123456abc'; #更新一下用户密码 
		
		
	2个slave 建立连接:	
		change master to master_host='192.168.0.101', master_port=3306, master_user='mharpl', master_password='123456abc', master_log_file='mysql-bin.000001', master_log_pos=154;
		start slave;
		show slave status\G;
		Last_IO_Error: Got fatal error 1236 from master when reading data from binary log: 
			'binlog truncated in the middle of event; consider out of disk space on master; 
			the first event 'mysql-bin.000001' at 154, the last event read from './mysql-bin.000001' at 124, the last byte read from './mysql-bin.000001' at 1316.'
		
		stop slave; 
		reset slave all;
		change master to master_host='192.168.0.101', master_port=3306, master_user='mharpl', master_password='123456abc', master_log_file='mysql-bin.000001', master_log_pos=151;
		start slave;
		show slave status\G;
		
		
		change master to master_host='192.168.0.101', master_port=3306, master_user='mharpl', master_password='123456abc', master_log_file='mysql-bin.000001', master_log_pos=151;
		start slave;
		show slave status\G;


	测试复制:
	主库上执行:
		mysql> create database test;
		Query OK, 1 row affected (0.00 sec)

		mysql> use test;
		Database changed
		mysql> create table t1(a int);
		Query OK, 0 rows affected (0.01 sec)

		mysql> insert into t1 values (1);
		Query OK, 1 row affected (0.00 sec)

	从库上执行:
		mysql> select * from test.t1;
		+------+
		| a    |
		+------+
		|    1 |
		+------+
		1 row in set (0.00 sec)


2.3 安装MHA Node

	3.1 MHA版本是0.56，并且在mha01、mha02、mha03 全部安装manager、node包
	
	3.2 安装MHA Node
		安装MHA Node软件包之前需要安装依赖:

			shell> yum install perl-DBD-MySQL
			
			shell> rpm -ivh mha4mysql-node-0.56-0.el6.noarch.rpm 
			Preparing...                          ################################# [100%]
			Updating / installing...
			   1:mha4mysql-node-0.56-0.el6        ################################# [100%]

			
			安装完成后，在/usr/bin/目录下有如下MHA相关文件：    #需要看看安装在这个目录是否正确

				apply_diff_relay_logs
				filter_mysqlbinlog
				purge_relay_logs
				save_binary_logs
				这些脚本工具通常由MHA Manager的脚本触发，无需人为操作。脚本说明：
					apply_diff_relay_logs ：识别差异的中继日志事件并将其差异的事件应用于其它slave。
					filter_mysqlbinlog ：去除不必要的ROLLBACK事件（MHA已不再使用这个工具）。
					purge_relay_logs ：清除中继日志（不会阻塞SQL线程）。
					save_binary_logs ：保存和复制master的二进制日志，用于补全最新从库跟宕机主库的差异binlog。
					
			
						
2.4 安装MHA Manager	

	2.4.1 MHA版本是0.56，并且在mha01、mha02、mha03 全部安装manager、node包
	
	
	2.4.2 先安装相关依赖包
	
		yum install perl-DBD-MySQL
		yum install perl-Config-Tiny
		yum install perl-Log-Dispatch  
			# 问题: No package perl-Log-Dispatch available.
			# 解决办法: yum install epel-release -y
				
		yum install perl-Parallel-ForkManager

	2.4.3
		shell> rpm -ivh mha4mysql-manager-0.56-0.el6.noarch.rpm
		Preparing...                          ################################# [100%]
		Updating / installing...
		1:mha4mysql-manager-0.56-0.el6     ################################# [100%]

        安装完成后，在/usr/bin/目录下有如下MHA相关文件：
		
		masterha_check_repl
		masterha_check_ssh
		masterha_check_status
		masterha_conf_host
		masterha_manager
		masterha_master_monitor
		masterha_master_switch
		masterha_secondary_check
		masterha_stop
		apply_diff_relay_logs
		filter_mysqlbinlog
		purge_relay_logs


3. 配置MHA	
	3.1 建立配置文件目录

		shell> mkdir -p /etc/masterha
		
	3.2 创建配置文件/etc/masterha/app1.cnf
	3.3 创建全局级配置文件：       /etc/masterha/masterha_default.conf
	3.4 建立软连接    
		ln -s /usr/local/mysql/bin/mysqlbinlog /usr/bin/mysqlbinlog
		ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql  
		
	3.5 设置复制中Slave的relay_log_purge参数, 在两台从库上执行
	mysql -uroot -p123456 -e "set global relay_log_purge=0"

4. 创建相关脚本
	4.1 创建自动failover脚本： /etc/masterha/master_ip_failover
	5.2 创建手动failover脚本   /etc/masterha/master_ip_online_change
	
	
5. 	查看/etc/masterha 目录下的所有文件
	shell> pwd
	/etc/masterha
	shell> ll
	total 28
	-rw-r--r--. 1 root root   799 Nov  6 14:28 app1.conf
	-rw-r--r--. 1 root root    57 Nov  6 14:28 init_vip.sh
	-rw-r--r--. 1 root root   594 Nov  6 14:28 masterha_default.conf
	-rw-r--r--. 1 root root  3980 Nov  6 14:28 master_ip_failover
	-rw-r--r--. 1 root root 10392 Nov  6 14:28 master_ip_online_change



	
7. 配置文件测试

7.1 测试 Ssh ok, 确认可以看到所有的服务器上 ssh 测试通过。

	shell>  masterha_check_ssh --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
	Wed Nov  6 14:30:04 2019 - [info] Reading default configuration from /etc/masterha/masterha_default.conf..
	Wed Nov  6 14:30:04 2019 - [info] Reading application default configuration from /etc/masterha/app1.conf..
	Wed Nov  6 14:30:04 2019 - [info] Reading server configuration from /etc/masterha/app1.conf..
	Wed Nov  6 14:30:04 2019 - [info] Starting SSH connection tests..
	Wed Nov  6 14:30:05 2019 - [debug] 
	Wed Nov  6 14:30:04 2019 - [debug]  Connecting via SSH from root@192.168.0.101(192.168.0.101:22) to root@192.168.0.102(192.168.0.102:22)..
	Warning: Permanently added '192.168.0.101' (ECDSA) to the list of known hosts.
	Wed Nov  6 14:30:04 2019 - [debug]   ok.
	Wed Nov  6 14:30:04 2019 - [debug]  Connecting via SSH from root@192.168.0.101(192.168.0.101:22) to root@192.168.0.103(192.168.0.103:22)..
	Wed Nov  6 14:30:05 2019 - [debug]   ok.
	Wed Nov  6 14:30:07 2019 - [debug] 
	Wed Nov  6 14:30:05 2019 - [debug]  Connecting via SSH from root@192.168.0.103(192.168.0.103:22) to root@192.168.0.101(192.168.0.101:22)..
	Wed Nov  6 14:30:05 2019 - [debug]   ok.
	Wed Nov  6 14:30:05 2019 - [debug]  Connecting via SSH from root@192.168.0.103(192.168.0.103:22) to root@192.168.0.102(192.168.0.102:22)..
	Wed Nov  6 14:30:06 2019 - [debug]   ok.
	Wed Nov  6 14:30:07 2019 - [debug] 
	Wed Nov  6 14:30:05 2019 - [debug]  Connecting via SSH from root@192.168.0.102(192.168.0.102:22) to root@192.168.0.101(192.168.0.101:22)..
	Warning: Permanently added '192.168.0.101' (ECDSA) to the list of known hosts.
	Wed Nov  6 14:30:05 2019 - [debug]   ok.
	Wed Nov  6 14:30:05 2019 - [debug]  Connecting via SSH from root@192.168.0.102(192.168.0.102:22) to root@192.168.0.103(192.168.0.103:22)..
	Wed Nov  6 14:30:06 2019 - [debug]   ok.
	Wed Nov  6 14:30:07 2019 - [info] All SSH connection tests passed successfully.
	
7.2 检查整个复制环境状况,  在 mha03 上用root用户操作。
	主要查看是不是具备跑 masterha_manger, 主从结构是不是 OK 之类。
	
	错误1:
	shell> masterha_check_repl --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
	
	Wed Nov  6 14:31:17 2019 - [info] Reading default configuration from /etc/masterha/masterha_default.conf..
	Wed Nov  6 14:31:17 2019 - [info] Reading application default configuration from /etc/masterha/app1.conf..
	Wed Nov  6 14:31:17 2019 - [info] Reading server configuration from /etc/masterha/app1.conf..
	Wed Nov  6 14:31:17 2019 - [info] MHA::MasterMonitor version 0.56.
	Creating directory /var/log/masterha/app1.. done.
	Wed Nov  6 14:31:18 2019 - [error][/usr/share/perl5/vendor_perl/MHA/ServerManager.pm, ln188] There is no alive server. We cant do failover
	Wed Nov  6 14:31:18 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln424] Error happened on checking configurations.  at /usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm line 326.
	Wed Nov  6 14:31:18 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln523] Error happened on monitoring servers.
	Wed Nov  6 14:31:18 2019 - [info] Got exit code 1 (Not master dead).

	MySQL Replication Health is NOT OK!
	
	
	# 防火墙确认已经关闭:
	[root@mha02 app1]# systemctl status firewalld.service
	● firewalld.service - firewalld - dynamic firewall daemon
	   Loaded: loaded (/usr/lib/systemd/system/firewalld.service; disabled; vendor preset: enabled)
	   Active: inactive (dead)
		 Docs: man:firewalld(1)
		 

	原因分析和解决办法:
		错误原因： Error happened on checking configurations、Error happened on monitoring servers, 说明了配置不对;
	
		解决办法:
			masterha_default.conf 配置文件的 MySQL的用户和密码, 不能用 root@'localhost' 这个账号
			
			添加 root@'%' 这个账号:
		
				create user root@'%' identified by '123456abc';
				grant all privileges on *.* to root@'%';
				ALTER USER root@'%' IDENTIFIED BY '123456abc' PASSWORD EXPIRE NEVER; #修改加密规则 
				ALTER USER root@'%' IDENTIFIED WITH mysql_native_password BY '123456abc'; #更新一下用户密码 
	成功1:
	[root@mha03 masterha]# masterha_check_repl --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
	Thu Nov  7 09:25:05 2019 - [info] Reading default configuration from /etc/masterha/masterha_default.conf..
	Thu Nov  7 09:25:05 2019 - [info] Reading application default configuration from /etc/masterha/app1.conf..
	Thu Nov  7 09:25:05 2019 - [info] Reading server configuration from /etc/masterha/app1.conf..
	Thu Nov  7 09:25:05 2019 - [info] MHA::MasterMonitor version 0.58.
	Thu Nov  7 09:25:06 2019 - [info] GTID failover mode = 1
	Thu Nov  7 09:25:06 2019 - [info] Dead Servers:
	Thu Nov  7 09:25:06 2019 - [info] Alive Servers:
	Thu Nov  7 09:25:06 2019 - [info]   192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 09:25:06 2019 - [info]   192.168.0.102(192.168.0.102:3306)
	Thu Nov  7 09:25:06 2019 - [info]   192.168.0.103(192.168.0.103:3306)
	Thu Nov  7 09:25:06 2019 - [info] Alive Slaves:
	Thu Nov  7 09:25:06 2019 - [info]   192.168.0.102(192.168.0.102:3306)  Version=8.0.18 (oldest major version between slaves) log-bin:enabled
	Thu Nov  7 09:25:06 2019 - [info]     GTID ON
	Thu Nov  7 09:25:06 2019 - [info]     Replicating from 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 09:25:06 2019 - [info]     Primary candidate for the new Master (candidate_master is set)
	Thu Nov  7 09:25:06 2019 - [info]   192.168.0.103(192.168.0.103:3306)  Version=8.0.18 (oldest major version between slaves) log-bin:enabled
	Thu Nov  7 09:25:06 2019 - [info]     GTID ON
	Thu Nov  7 09:25:06 2019 - [info]     Replicating from 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 09:25:06 2019 - [info] Current Alive Master: 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 09:25:06 2019 - [info] Checking slave configurations..
	Thu Nov  7 09:25:06 2019 - [info] Checking replication filtering settings..
	Thu Nov  7 09:25:06 2019 - [info]  binlog_do_db= , binlog_ignore_db= 
	Thu Nov  7 09:25:06 2019 - [info]  Replication filtering check ok.
	Thu Nov  7 09:25:06 2019 - [info] GTID (with auto-pos) is supported. Skipping all SSH and Node package checking.
	Thu Nov  7 09:25:06 2019 - [info] Checking SSH publickey authentication settings on the current master..
	Thu Nov  7 09:25:06 2019 - [info] HealthCheck: SSH to 192.168.0.101 is reachable.
	Thu Nov  7 09:25:06 2019 - [info] 
	192.168.0.101(192.168.0.101:3306) (current master)
	 +--192.168.0.102(192.168.0.102:3306)
	 +--192.168.0.103(192.168.0.103:3306)

	Thu Nov  7 09:25:06 2019 - [info] Checking replication health on 192.168.0.102..
	Thu Nov  7 09:25:06 2019 - [info]  ok.
	Thu Nov  7 09:25:06 2019 - [info] Checking replication health on 192.168.0.103..
	Thu Nov  7 09:25:06 2019 - [info]  ok.
	Thu Nov  7 09:25:06 2019 - [info] Checking master_ip_failover_script status:
	Thu Nov  7 09:25:06 2019 - [info]   /etc/masterha/master_ip_failover --command=status --ssh_user=root --orig_master_host=192.168.0.101 --orig_master_ip=192.168.0.101 --orig_master_port=3306 
	Thu Nov  7 09:25:06 2019 - [info]  OK.
	Thu Nov  7 09:25:06 2019 - [warning] shutdown_script is not defined.
	Thu Nov  7 09:25:06 2019 - [info] Got exit code 0 (Not master dead).

	MySQL Replication Health is OK.
		

		
	错误2:	
	[root@mha03 app1]# masterha_check_repl --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
	Thu Nov  7 10:07:54 2019 - [info] Reading default configuration from /etc/masterha/masterha_default.conf..
	Thu Nov  7 10:07:54 2019 - [info] Reading application default configuration from /etc/masterha/app1.conf..
	Thu Nov  7 10:07:54 2019 - [info] Reading server configuration from /etc/masterha/app1.conf..
	Thu Nov  7 10:07:54 2019 - [info] MHA::MasterMonitor version 0.58.
	Thu Nov  7 10:07:55 2019 - [info] GTID failover mode = 0
	Thu Nov  7 10:07:55 2019 - [info] Dead Servers:
	Thu Nov  7 10:07:55 2019 - [info] Alive Servers:
	Thu Nov  7 10:07:55 2019 - [info]   192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 10:07:55 2019 - [info]   192.168.0.102(192.168.0.102:3306)
	Thu Nov  7 10:07:55 2019 - [info]   192.168.0.103(192.168.0.103:3306)
	Thu Nov  7 10:07:55 2019 - [info] Alive Slaves:
	Thu Nov  7 10:07:55 2019 - [info]   192.168.0.102(192.168.0.102:3306)  Version=8.0.18 (oldest major version between slaves) log-bin:enabled
	Thu Nov  7 10:07:55 2019 - [info]     Replicating from 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 10:07:55 2019 - [info]     Primary candidate for the new Master (candidate_master is set)
	Thu Nov  7 10:07:55 2019 - [info]   192.168.0.103(192.168.0.103:3306)  Version=8.0.18 (oldest major version between slaves) log-bin:enabled
	Thu Nov  7 10:07:55 2019 - [info]     Replicating from 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 10:07:55 2019 - [info]     Primary candidate for the new Master (candidate_master is set)
	Thu Nov  7 10:07:55 2019 - [info] Current Alive Master: 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 10:07:55 2019 - [info] Checking slave configurations..
	Thu Nov  7 10:07:55 2019 - [info]  read_only=1 is not set on slave 192.168.0.102(192.168.0.102:3306).
	Thu Nov  7 10:07:55 2019 - [warning]  relay_log_purge=0 is not set on slave 192.168.0.102(192.168.0.102:3306).
	Thu Nov  7 10:07:55 2019 - [info]  read_only=1 is not set on slave 192.168.0.103(192.168.0.103:3306).
	Thu Nov  7 10:07:55 2019 - [warning]  relay_log_purge=0 is not set on slave 192.168.0.103(192.168.0.103:3306).
	Thu Nov  7 10:07:55 2019 - [info] Checking replication filtering settings..
	Thu Nov  7 10:07:55 2019 - [info]  binlog_do_db= , binlog_ignore_db= 
	Thu Nov  7 10:07:55 2019 - [info]  Replication filtering check ok.
	Thu Nov  7 10:07:55 2019 - [info] GTID (with auto-pos) is not supported
	Thu Nov  7 10:07:55 2019 - [info] Starting SSH connection tests..
	Thu Nov  7 10:07:57 2019 - [info] All SSH connection tests passed successfully.
	Thu Nov  7 10:07:57 2019 - [info] Checking MHA Node version..
	Thu Nov  7 10:07:58 2019 - [info]  Version check ok.
	Thu Nov  7 10:07:58 2019 - [info] Checking SSH publickey authentication settings on the current master..
	Thu Nov  7 10:07:58 2019 - [info] HealthCheck: SSH to 192.168.0.101 is reachable.
	Thu Nov  7 10:07:58 2019 - [info] Master MHA Node version is 0.58.
	Thu Nov  7 10:07:58 2019 - [info] Checking recovery script configurations on 192.168.0.101(192.168.0.101:3306)..
	Thu Nov  7 10:07:58 2019 - [info]   Executing command: save_binary_logs --command=test --start_pos=4 --binlog_dir=/data/mysql/mysql3306/logs --output_file=/var/log/masterha/app1/save_binary_logs_test --manager_version=0.58 --start_file=mysql-bin.000005 
	Thu Nov  7 10:07:58 2019 - [info]   Connecting to root@192.168.0.101(192.168.0.101:22).. 
	Failed to save binary log: Binlog not found from /data/mysql/mysql3306/logs! If you got this error at MHA Manager, please set "master_binlog_dir=/path/to/binlog_directory_of_the_master" correctly in the MHA Manager s configuration file and try again.
	 at /usr/bin/save_binary_logs line 123.
		eval {...} called at /usr/bin/save_binary_logs line 70
		main::main() called at /usr/bin/save_binary_logs line 66
	Thu Nov  7 10:07:59 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln161] Binlog setting check failed!
	Thu Nov  7 10:07:59 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln408] Master configuration failed.
	Thu Nov  7 10:07:59 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln427] Error happened on checking configurations.  at /usr/bin/masterha_check_repl line 48.
	Thu Nov  7 10:07:59 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln525] Error happened on monitoring servers.
	Thu Nov  7 10:07:59 2019 - [info] Got exit code 1 (Not master dead).

	MySQL Replication Health is NOT OK!

	# 原因:  binlog 不是保存在 /data/mysql/mysql3306/logs 这个目录下
	
	
	错误3:
	[root@mha03 masterha]# masterha_check_repl --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
	Thu Nov  7 12:11:42 2019 - [info] Reading default configuration from /etc/masterha/masterha_default.conf..
	Thu Nov  7 12:11:42 2019 - [info] Reading application default configuration from /etc/masterha/app1.conf..
	Thu Nov  7 12:11:42 2019 - [info] Reading server configuration from /etc/masterha/app1.conf..
	Thu Nov  7 12:11:42 2019 - [info] MHA::MasterMonitor version 0.58.
	Thu Nov  7 12:11:43 2019 - [info] GTID failover mode = 0
	Thu Nov  7 12:11:43 2019 - [info] Dead Servers:
	Thu Nov  7 12:11:43 2019 - [info] Alive Servers:
	Thu Nov  7 12:11:43 2019 - [info]   192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 12:11:43 2019 - [info]   192.168.0.102(192.168.0.102:3306)
	Thu Nov  7 12:11:43 2019 - [info]   192.168.0.103(192.168.0.103:3306)
	Thu Nov  7 12:11:43 2019 - [info] Alive Slaves:
	Thu Nov  7 12:11:43 2019 - [info]   192.168.0.102(192.168.0.102:3306)  Version=8.0.18 (oldest major version between slaves) log-bin:enabled
	Thu Nov  7 12:11:43 2019 - [info]     Replicating from 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 12:11:43 2019 - [info]     Primary candidate for the new Master (candidate_master is set)
	Thu Nov  7 12:11:43 2019 - [info]   192.168.0.103(192.168.0.103:3306)  Version=8.0.18 (oldest major version between slaves) log-bin:enabled
	Thu Nov  7 12:11:43 2019 - [info]     Replicating from 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 12:11:43 2019 - [info]     Primary candidate for the new Master (candidate_master is set)
	Thu Nov  7 12:11:43 2019 - [info] Current Alive Master: 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 12:11:43 2019 - [info] Checking slave configurations..
	Thu Nov  7 12:11:43 2019 - [info]  read_only=1 is not set on slave 192.168.0.102(192.168.0.102:3306).
	Thu Nov  7 12:11:43 2019 - [warning]  relay_log_purge=0 is not set on slave 192.168.0.102(192.168.0.102:3306).
	Thu Nov  7 12:11:43 2019 - [info]  read_only=1 is not set on slave 192.168.0.103(192.168.0.103:3306).
	Thu Nov  7 12:11:43 2019 - [warning]  relay_log_purge=0 is not set on slave 192.168.0.103(192.168.0.103:3306).
	Thu Nov  7 12:11:43 2019 - [info] Checking replication filtering settings..
	Thu Nov  7 12:11:43 2019 - [info]  binlog_do_db= , binlog_ignore_db= 
	Thu Nov  7 12:11:43 2019 - [info]  Replication filtering check ok.
	Thu Nov  7 12:11:43 2019 - [info] GTID (with auto-pos) is not supported
	Thu Nov  7 12:11:43 2019 - [info] Starting SSH connection tests..
	Thu Nov  7 12:11:46 2019 - [info] All SSH connection tests passed successfully.
	Thu Nov  7 12:11:46 2019 - [info] Checking MHA Node version..
	Thu Nov  7 12:11:46 2019 - [info]  Version check ok.
	Thu Nov  7 12:11:46 2019 - [info] Checking SSH publickey authentication settings on the current master..
	Thu Nov  7 12:11:47 2019 - [info] HealthCheck: SSH to 192.168.0.101 is reachable.
	Thu Nov  7 12:11:47 2019 - [info] Master MHA Node version is 0.58.
	Thu Nov  7 12:11:47 2019 - [info] Checking recovery script configurations on 192.168.0.101(192.168.0.101:3306)..
	Thu Nov  7 12:11:47 2019 - [info]   Executing command: save_binary_logs --command=test --start_pos=4 --binlog_dir=/data/mysql/mysql3306/data --output_file=/var/log/masterha/app1/save_binary_logs_test --manager_version=0.58 --start_file=mysql-bin.000008 
	Thu Nov  7 12:11:47 2019 - [info]   Connecting to root@192.168.0.101(192.168.0.101:22).. 
	  Creating /var/log/masterha/app1 if not exists..    ok.
	  Checking output directory is accessible or not..
	   ok.
	  Binlog found at /data/mysql/mysql3306/data, up to mysql-bin.000008
	Thu Nov  7 12:11:47 2019 - [info] Binlog setting check done.
	Thu Nov  7 12:11:47 2019 - [info] Checking SSH publickey authentication and checking recovery script configurations on all alive slave servers..
	Thu Nov  7 12:11:47 2019 - [info]   Executing command : apply_diff_relay_logs --command=test --slave_user='root' --slave_host=192.168.0.102 --slave_ip=192.168.0.102 --slave_port=3306 --workdir=/var/log/masterha/app1 --target_version=8.0.18 --manager_version=0.58 --relay_dir=/data/mysql/mysql3306/data --current_relay_log=mha02-relay-bin.000023  --slave_pass=xxx
	Thu Nov  7 12:11:47 2019 - [info]   Connecting to root@192.168.0.102(192.168.0.102:22).. 
	Can t exec "mysqlbinlog": No such file or directory at /usr/share/perl5/vendor_perl/MHA/BinlogManager.pm line 106.
	mysqlbinlog version command failed with rc 1:0, please verify PATH, LD_LIBRARY_PATH, and client options
	 at /usr/bin/apply_diff_relay_logs line 532.
	Thu Nov  7 12:11:47 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln208] Slaves settings check failed!
	Thu Nov  7 12:11:47 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln416] Slave configuration failed.
	Thu Nov  7 12:11:47 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln427] Error happened on checking configurations.  at /usr/bin/masterha_check_repl line 48.
	Thu Nov  7 12:11:47 2019 - [error][/usr/share/perl5/vendor_perl/MHA/MasterMonitor.pm, ln525] Error happened on monitoring servers.
	Thu Nov  7 12:11:47 2019 - [info] Got exit code 1 (Not master dead).

	MySQL Replication Health is NOT OK!

	
	解决办法:
	在所有节点上执行
		ln -s /usr/local/mysql/bin/mysqlbinlog /usr/bin/mysqlbinlog
		ln -s /usr/local/mysql/bin/mysql       /usr/bin/mysql  

		
	成功2:
	[root@mha03 masterha]# masterha_check_repl --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
	Thu Nov  7 12:16:27 2019 - [info] Reading default configuration from /etc/masterha/masterha_default.conf..
	Thu Nov  7 12:16:27 2019 - [info] Reading application default configuration from /etc/masterha/app1.conf..
	Thu Nov  7 12:16:27 2019 - [info] Reading server configuration from /etc/masterha/app1.conf..
	Thu Nov  7 12:16:27 2019 - [info] MHA::MasterMonitor version 0.58.
	Thu Nov  7 12:16:28 2019 - [info] GTID failover mode = 0
	Thu Nov  7 12:16:28 2019 - [info] Dead Servers:
	Thu Nov  7 12:16:28 2019 - [info] Alive Servers:
	Thu Nov  7 12:16:28 2019 - [info]   192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 12:16:28 2019 - [info]   192.168.0.102(192.168.0.102:3306)
	Thu Nov  7 12:16:28 2019 - [info]   192.168.0.103(192.168.0.103:3306)
	Thu Nov  7 12:16:28 2019 - [info] Alive Slaves:
	Thu Nov  7 12:16:28 2019 - [info]   192.168.0.102(192.168.0.102:3306)  Version=8.0.18 (oldest major version between slaves) log-bin:enabled
	Thu Nov  7 12:16:28 2019 - [info]     Replicating from 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 12:16:28 2019 - [info]     Primary candidate for the new Master (candidate_master is set)
	Thu Nov  7 12:16:28 2019 - [info]   192.168.0.103(192.168.0.103:3306)  Version=8.0.18 (oldest major version between slaves) log-bin:enabled
	Thu Nov  7 12:16:28 2019 - [info]     Replicating from 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 12:16:28 2019 - [info]     Primary candidate for the new Master (candidate_master is set)
	Thu Nov  7 12:16:28 2019 - [info] Current Alive Master: 192.168.0.101(192.168.0.101:3306)
	Thu Nov  7 12:16:28 2019 - [info] Checking slave configurations..
	Thu Nov  7 12:16:28 2019 - [info]  read_only=1 is not set on slave 192.168.0.102(192.168.0.102:3306).
	Thu Nov  7 12:16:28 2019 - [warning]  relay_log_purge=0 is not set on slave 192.168.0.102(192.168.0.102:3306).
	Thu Nov  7 12:16:28 2019 - [info]  read_only=1 is not set on slave 192.168.0.103(192.168.0.103:3306).
	Thu Nov  7 12:16:28 2019 - [warning]  relay_log_purge=0 is not set on slave 192.168.0.103(192.168.0.103:3306).
	Thu Nov  7 12:16:28 2019 - [info] Checking replication filtering settings..
	Thu Nov  7 12:16:28 2019 - [info]  binlog_do_db= , binlog_ignore_db= 
	Thu Nov  7 12:16:28 2019 - [info]  Replication filtering check ok.
	Thu Nov  7 12:16:28 2019 - [info] GTID (with auto-pos) is not supported
	Thu Nov  7 12:16:28 2019 - [info] Starting SSH connection tests..
	Thu Nov  7 12:16:31 2019 - [info] All SSH connection tests passed successfully.
	Thu Nov  7 12:16:31 2019 - [info] Checking MHA Node version..
	Thu Nov  7 12:16:31 2019 - [info]  Version check ok.
	Thu Nov  7 12:16:31 2019 - [info] Checking SSH publickey authentication settings on the current master..
	Thu Nov  7 12:16:32 2019 - [info] HealthCheck: SSH to 192.168.0.101 is reachable.
	Thu Nov  7 12:16:32 2019 - [info] Master MHA Node version is 0.58.
	Thu Nov  7 12:16:32 2019 - [info] Checking recovery script configurations on 192.168.0.101(192.168.0.101:3306)..
	Thu Nov  7 12:16:32 2019 - [info]   Executing command: save_binary_logs --command=test --start_pos=4 --binlog_dir=/data/mysql/mysql3306/data --output_file=/var/log/masterha/app1/save_binary_logs_test --manager_version=0.58 --start_file=mysql-bin.000008 
	Thu Nov  7 12:16:32 2019 - [info]   Connecting to root@192.168.0.101(192.168.0.101:22).. 
	  Creating /var/log/masterha/app1 if not exists..    ok.
	  Checking output directory is accessible or not..
	   ok.
	  Binlog found at /data/mysql/mysql3306/data, up to mysql-bin.000008
	Thu Nov  7 12:16:32 2019 - [info] Binlog setting check done.
	Thu Nov  7 12:16:32 2019 - [info] Checking SSH publickey authentication and checking recovery script configurations on all alive slave servers..
	Thu Nov  7 12:16:32 2019 - [info]   Executing command : apply_diff_relay_logs --command=test --slave_user='root' --slave_host=192.168.0.102 --slave_ip=192.168.0.102 --slave_port=3306 --workdir=/var/log/masterha/app1 --target_version=8.0.18 --manager_version=0.58 --relay_dir=/data/mysql/mysql3306/data --current_relay_log=mha02-relay-bin.000023  --slave_pass=xxx
	Thu Nov  7 12:16:32 2019 - [info]   Connecting to root@192.168.0.102(192.168.0.102:22).. 
	  Checking slave recovery environment settings..
		Relay log found at /data/mysql/mysql3306/data, up to mha02-relay-bin.000023
		Temporary relay log file is /data/mysql/mysql3306/data/mha02-relay-bin.000023
		Checking if super_read_only is defined and turned on.. not present or turned off, ignoring.
		Testing mysql connection and privileges..
	mysql: [Warning] Using a password on the command line interface can be insecure.
	 done.
		Testing mysqlbinlog output.. done.
		Cleaning up test file(s).. done.
	Thu Nov  7 12:16:33 2019 - [info]   Executing command : apply_diff_relay_logs --command=test --slave_user='root' --slave_host=192.168.0.103 --slave_ip=192.168.0.103 --slave_port=3306 --workdir=/var/log/masterha/app1 --target_version=8.0.18 --manager_version=0.58 --relay_dir=/data/mysql/mysql3306/data --current_relay_log=mha03-relay-bin.000024  --slave_pass=xxx
	Thu Nov  7 12:16:33 2019 - [info]   Connecting to root@192.168.0.103(192.168.0.103:22).. 
	  Checking slave recovery environment settings..
		Relay log found at /data/mysql/mysql3306/data, up to mha03-relay-bin.000024
		Temporary relay log file is /data/mysql/mysql3306/data/mha03-relay-bin.000024
		Checking if super_read_only is defined and turned on.. not present or turned off, ignoring.
		Testing mysql connection and privileges..
	mysql: [Warning] Using a password on the command line interface can be insecure.
	 done.
		Testing mysqlbinlog output.. done.
		Cleaning up test file(s).. done.
	Thu Nov  7 12:16:33 2019 - [info] Slaves settings check done.
	Thu Nov  7 12:16:33 2019 - [info] 
	192.168.0.101(192.168.0.101:3306) (current master)
	 +--192.168.0.102(192.168.0.102:3306)
	 +--192.168.0.103(192.168.0.103:3306)

	Thu Nov  7 12:16:33 2019 - [info] Checking replication health on 192.168.0.102..
	Thu Nov  7 12:16:33 2019 - [info]  ok.
	Thu Nov  7 12:16:33 2019 - [info] Checking replication health on 192.168.0.103..
	Thu Nov  7 12:16:33 2019 - [info]  ok.
	Thu Nov  7 12:16:33 2019 - [info] Checking master_ip_failover_script status:
	Thu Nov  7 12:16:33 2019 - [info]   /etc/masterha/master_ip_failover --command=status --ssh_user=root --orig_master_host=192.168.0.101 --orig_master_ip=192.168.0.101 --orig_master_port=3306 
	Thu Nov  7 12:16:33 2019 - [info]  OK.
	Thu Nov  7 12:16:33 2019 - [warning] shutdown_script is not defined.
	Thu Nov  7 12:16:33 2019 - [info] Got exit code 0 (Not master dead).

	MySQL Replication Health is OK.


8. 	MHA的启动和关闭	

	启动MHA:
		nohup masterha_manager --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf --ignore_last_failover > /tmp/mha_manager.log 2>&1 &
		
		参数说明:
			--ignore_last_failover
				在缺省情况下，如果 MHA 检测到连续发生宕机，且两次宕机间隔不足 8 小时的话，则不会进行 Failover，之所以这样限制是为了避免 ping-pong 效应。
				该参数代表忽略上次 MHA 触发切换产生的文件，默认情况下，MHA 发生切换后会在日志目录，也就是上面我设置的/var/log/masterha/app1/产生 app1.failover.complete 文件，
				下次再次切换的时候如果发现该目录下存在该文件将不允许触发切换，除非在第一次切换后收到删除该文件，为了方便，这里设置为 --ignore_last_failover。
				日志提示如下:
					 Last failover was done at 2019/11/07 14:42:03. Current time is too early to do failover again. If you want to do failover, manually remove /var/log/masterha/app1/app1.failover.complete and run this script again.

			
		tail -f /tmp/mha_manager.log:
		Thu Nov  7 09:36:34 2019 - [info] Reading default configuration from /etc/masterha/masterha_default.conf..
		Thu Nov  7 09:36:34 2019 - [info] Reading application default configuration from /etc/masterha/app1.conf..
		Thu Nov  7 09:36:34 2019 - [info] Reading server configuration from /etc/masterha/app1.conf..
		
	
	关闭 MHA:
		shell> masterha_stop --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
	
	检查MHA Manager的状态
		shell> masterha_check_status --global_conf=/etc/masterha/masterha_default.conf --conf=/etc/masterha/app1.conf
		app1 (pid:6832) is running(0:PING_OK), master:192.168.0.101
		可以看见已经在监控了，而且master的主机为192.168.0.101。
		
	
9. 绑定VIP
1. 初始绑定VIP, 在主节点初始化VIP
	[root@mha01 masterha]# bash -x init_vip.sh 

	查看IP:
		[root@mha01 masterha]# ip addr show
		1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
			link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
			inet 127.0.0.1/8 scope host lo
			   valid_lft forever preferred_lft forever
			inet6 ::1/128 scope host 
			   valid_lft forever preferred_lft forever
		2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
			link/ether 08:00:27:46:17:cc brd ff:ff:ff:ff:ff:ff
			inet 192.168.0.101/24 brd 192.168.0.255 scope global enp0s3
			   valid_lft forever preferred_lft forever
			inet 192.168.0.104/32 scope global enp0s3
			   valid_lft forever preferred_lft forever
			inet6 fe80::a00:27ff:fe46:17cc/64 scope link 
			   valid_lft forever preferred_lft forever

	
	
	

	