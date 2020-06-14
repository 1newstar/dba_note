/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=1*/;
/*!50003 SET @OLD_COMPLETION_TYPE=@@COMPLETION_TYPE,COMPLETION_TYPE=0*/;
DELIMITER /*!*/;
# at 4
#200321 12:22:56 server id 293306  end_log_pos 123 CRC32 0x39bf74e5 	Start: binlog v 4, server v 5.7.19-log created 200321 12:22:56
# at 123
#200321 12:22:56 server id 293306  end_log_pos 194 CRC32 0x3dc30d5a 	Previous-GTIDs
# f7323d17-6442-11ea-8a77-080027758761:15-110684
# at 194
#200321 12:24:42 server id 273306  end_log_pos 259 CRC32 0x5e6b67a1 	GTID	last_committed=0	sequence_number=1	rbr_only=yes
/*!50718 SET TRANSACTION ISOLATION LEVEL READ COMMITTED*//*!*/;
SET @@SESSION.GTID_NEXT= 'f7323d17-6442-11ea-8a77-080027758761:110685'/*!*/;
# at 259
#200321 12:24:42 server id 273306  end_log_pos 322 CRC32 0x9a1fec6c 	Query	thread_id=80	exec_time=0	error_code=0
SET TIMESTAMP=1584764682/*!*/;
SET @@session.pseudo_thread_id=80/*!*/;
SET @@session.foreign_key_checks=1, @@session.sql_auto_is_null=0, @@session.unique_checks=1, @@session.autocommit=1/*!*/;
SET @@session.sql_mode=524288/*!*/;
SET @@session.auto_increment_increment=1, @@session.auto_increment_offset=1/*!*/;
/*!\C utf8 *//*!*/;
SET @@session.character_set_client=33,@@session.collation_connection=33,@@session.collation_server=33/*!*/;
SET @@session.lc_time_names=0/*!*/;
SET @@session.collation_database=DEFAULT/*!*/;
BEGIN
/*!*/;
# at 322
#200321 12:24:42 server id 273306  end_log_pos 370 CRC32 0xfffd8367 	Table_map: `db3`.`t2` mapped to number 406
# at 370
#200321 12:24:42 server id 273306  end_log_pos 420 CRC32 0x919c73c8 	Write_rows: table id 406 flags: STMT_END_F
### INSERT INTO `db3`.`t2`
### SET
###   @1=4 /* LONGINT meta=0 nullable=0 is_null=0 */
###   @2='1' /* VARSTRING(80) meta=80 nullable=1 is_null=0 */
###   @3=2 /* INT meta=0 nullable=1 is_null=0 */
# at 420
#200321 12:24:42 server id 273306  end_log_pos 451 CRC32 0x1e691e22 	Xid = 106
COMMIT/*!*/;
# at 451
#200321 12:24:42 server id 273306  end_log_pos 516 CRC32 0x40ffdc3b 	GTID	last_committed=1	sequence_number=2	rbr_only=yes
/*!50718 SET TRANSACTION ISOLATION LEVEL READ COMMITTED*//*!*/;
SET @@SESSION.GTID_NEXT= 'f7323d17-6442-11ea-8a77-080027758761:110686'/*!*/;
# at 516
#200321 12:24:42 server id 273306  end_log_pos 579 CRC32 0xda1d096a 	Query	thread_id=80	exec_time=0	error_code=0
SET TIMESTAMP=1584764682/*!*/;
BEGIN
/*!*/;
# at 579
#200321 12:24:42 server id 273306  end_log_pos 627 CRC32 0xfb0765a3 	Table_map: `db3`.`t1` mapped to number 407
# at 627
#200321 12:24:42 server id 273306  end_log_pos 677 CRC32 0x00fdf0c5 	Write_rows: table id 407 flags: STMT_END_F
### INSERT INTO `db3`.`t1`
### SET
###   @1=4 /* LONGINT meta=0 nullable=0 is_null=0 */
###   @2='1' /* VARSTRING(80) meta=80 nullable=1 is_null=0 */
###   @3=2 /* INT meta=0 nullable=1 is_null=0 */
# at 677
#200321 12:24:42 server id 273306  end_log_pos 708 CRC32 0x0001d1ab 	Xid = 108
COMMIT/*!*/;
# at 708
#200321 12:24:54 server id 273306  end_log_pos 773 CRC32 0x303b063d 	GTID	last_committed=2	sequence_number=3	rbr_only=no
SET @@SESSION.GTID_NEXT= 'f7323d17-6442-11ea-8a77-080027758761:110687'/*!*/;
# at 773
#200321 12:24:54 server id 273306  end_log_pos 886 CRC32 0x09001c7a 	Query	thread_id=80	exec_time=0	error_code=0
use `db3`/*!*/;
SET TIMESTAMP=1584764694/*!*/;
SET @@session.sql_mode=1436549152/*!*/;
DROP TABLE `t1` /* generated by server */
/*!*/;
# at 886
#200321 12:24:55 server id 273306  end_log_pos 951 CRC32 0x5662cd25 	GTID	last_committed=3	sequence_number=4	rbr_only=yes
/*!50718 SET TRANSACTION ISOLATION LEVEL READ COMMITTED*//*!*/;
SET @@SESSION.GTID_NEXT= 'f7323d17-6442-11ea-8a77-080027758761:110688'/*!*/;
# at 951
#200321 12:24:55 server id 273306  end_log_pos 1014 CRC32 0x47fa1a82 	Query	thread_id=80	exec_time=4294967295	error_code=0
SET TIMESTAMP=1584764695/*!*/;
SET @@session.sql_mode=524288/*!*/;
BEGIN
/*!*/;
# at 1014
#200321 12:24:55 server id 273306  end_log_pos 1062 CRC32 0x2f4f6a81 	Table_map: `db3`.`t2` mapped to number 406
# at 1062
#200321 12:24:55 server id 273306  end_log_pos 1112 CRC32 0xa18ece93 	Write_rows: table id 406 flags: STMT_END_F
### INSERT INTO `db3`.`t2`
### SET
###   @1=5 /* LONGINT meta=0 nullable=0 is_null=0 */
###   @2='1' /* VARSTRING(80) meta=80 nullable=1 is_null=0 */
###   @3=2 /* INT meta=0 nullable=1 is_null=0 */
# at 1112
#200321 12:24:55 server id 273306  end_log_pos 1143 CRC32 0xe9948ac3 	Xid = 111
COMMIT/*!*/;
# at 1143
#200321 12:33:16 server id 293306  end_log_pos 1166 CRC32 0xfb0b7812 	Stop
SET @@SESSION.GTID_NEXT= 'AUTOMATIC' /* added by mysqlbinlog */ /*!*/;
DELIMITER ;
# End of log file
/*!50003 SET COMPLETION_TYPE=@OLD_COMPLETION_TYPE*/;
/*!50530 SET @@SESSION.PSEUDO_SLAVE_MODE=0*/;
