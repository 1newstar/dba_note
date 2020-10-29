

https://github.com/danfengcao/binlog2sql



create user 'binlog2sql'@'%' identified by '123456';
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'binlog2sql'@'192.168.0.%' with grant option;
	
	
	
	
python3 binlog2sql.py -h192.168.0.54 -P3306 -ubinlog2sql -p'123456abc' -dsql_db -tt1 --start-file='mysql-bin.000063' --start-datetime='2019-04-12 02:00:00' --stop-datetime='2018-04-12 17:10:00'
python3 binlog2sql.py --flashback -h192.168.0.54 -P3306 -ubinlog2sql -p'123456abc' -dsql_db -tt1 --start-file='mysql-bin.000063' --start-datetime='2019-04-12 02:00:00'  -B > rollback.sql | cat


python3 binlog2sql.py  -h192.168.0.252 -P3306 -uljb_user -p'ljb032@Ly2019%' -dkpi --start-file='mysql-bin.000093' --start-datetime='2019-04-17 09:17:58' --start-position=1683 --stop-position=1913


python binlog2sql.py -h192.168.1.26 -P3306 -ubinlog2sql -p'123456abc' -dzst -tcron_test --start-file='mysql-bin.000028' --start-datetime='2018-04-07 17:00:38' --stop-datetime='2018-04-07 17:01:29' -B > rollback.sql | cat
python binlog2sql.py -h192.168.1.26 -P3306 -ubinlog2sql -p'123456abc' -dzst -tcron_test --start-file='mysql-bin.000028' --start-datetime='2018-04-07 16:35:09' --stop-datetime='2018-04-07 16:35:09' -B > rollback.sql | cat

mysql -h192.168.1.26 -P3306 -ubinlog2sql -p'123456abc' < rollback.sql

mysql: [Warning] Using a password on the command line interface can be insecure.
ERROR 1142 (42000) at line 2: DROP command denied to user 'binlog2sql'@'env' for table 'cron_test'


GRANT ALL PRIVILEGES ON *.* TO 'binlog2sqls'@'192.168.1.%' IDENTIFIED BY '123456abc';
mysql -h192.168.1.26 -P3306 -ubinlog2sqls -p'123456abc' < rollback.sql

��;
1�����ݿ��ٻع�(����)
2�������л�����master�����ݵ��޸�
3����binlog���ɱ�׼SQL����������������

1���鿴���µ�binlog��־�ļ�

2����ʱ�䷶Χ��ȷ�� ��ʼλ�úͽ���λ��
python binlog2sql.py -h192.168.95.228 -P3306 -ubinsql -p'123456abc' -dbin2sql -tserversys --start-file='mysql-bin.000046' --start-datetime='2018-03-05 17:00:00' --stop-datetime='2018-03-05 19:00:00'

3��
python binlog2sql.py -h192.168.95.228 -P3306 -ubinsql -p'123456abc' -dbin2sql -tserversys --start-file='mysql-bin.000046' --start-position=259 --stop-position=504 -B > rollback.sql | cat

error:
 u"log event entry exceeded max_allowed_packet; Increase max_allowed_packet on master; the first event 
 
 ԭ��
  --start-position=259 û��д��ȷ

4���鿴�ع�SQL�Ƿ���ȷ  
	cat rollback.sql
5��ִ�лع� 
mysql -h192.168.95.228 -P3306 -ubinsql -p'123456abc' < rollback.sql

6����֤�ع��������Ƿ���ȷ


delete->insert
insert->delete
update->udpate


python binlog2sql.py -h192.168.95.228 -P3306 -ubinsql -p'123456abc' -dbin2sql -tserversys --start-file='mysql-bin.000047' --start-datetime='2018-03-05 19:00:00' --stop-datetime='2018-03-05 19:35:00'


python binlog2sql.py -h192.168.95.228 -P3306 -ubinsql -p'123456abc' -dbin2sql -tserversys --start-file='mysql-bin.000047' --start-position=593 --stop-position=906 -B > rollback_update.sql

mysql -h192.168.95.228 -P3306 -ubinsql -p'123456abc' < rollback_update.sql