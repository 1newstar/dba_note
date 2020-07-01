

CREATE TABLE t1 (
	id INT NOT NULL AUTO_INCREMENT,
	key1 VARCHAR(100),
	key2 INT,
	key3 VARCHAR(100),
	common_field VARCHAR(100),
	PRIMARY KEY (id),
	KEY idx_key1 (key1)
) Engine=InnoDB CHARSET=utf8mb4;


CREATE TABLE t2 (
	id INT NOT NULL AUTO_INCREMENT,
	key1 VARCHAR(100),
	key2 INT,
	key3 VARCHAR(100),
	common_field VARCHAR(100),
	PRIMARY KEY (id),
	KEY idx_key1 (key1)
) Engine=InnoDB CHARSET=utf8mb4;


--------------------------------------------------------------------------------------------

root@localhost [db1]>select * from t1;
+----+------+------+------+--------------+
| id | key1 | key2 | key3 | common_field |
+----+------+------+------+--------------+
|  1 | 1    |    1 | 1    | 1            |
|  2 | 1    |    1 | 1    | 1            |
+----+------+------+------+--------------+
2 rows in set (0.00 sec)

root@localhost [db1]>select * from t2;
+----+------+------+------+--------------+
| id | key1 | key2 | key3 | common_field |
+----+------+------+------+--------------+
|  1 | 1    |    1 | 1    | 1            |
+----+------+------+------+--------------+
1 row in set (0.01 sec)


root@localhost [db1]> SELECT * FROM t1  WHERE key1 IN (SELECT common_field FROM t2 WHERE key3 = '1');
+----+------+------+------+--------------+
| id | key1 | key2 | key3 | common_field |
+----+------+------+------+--------------+
|  1 | 1    |    1 | 1    | 1            |
|  2 | 1    |    1 | 1    | 1            |
+----+------+------+------+--------------+
2 rows in set (0.00 sec)


root@localhost [db1]>SELECT t1.* FROM t1 INNER JOIN t2 ON t1.key1 = t2.common_field WHERE t2.key3 = '1';
+----+------+------+------+--------------+
| id | key1 | key2 | key3 | common_field |
+----+------+------+------+--------------+
|  1 | 1    |    1 | 1    | 1            |
|  2 | 1    |    1 | 1    | 1            |
+----+------+------+------+--------------+
2 rows in set (0.00 sec)


--------------------------------------------------------------------------------------------

root@localhost [db1]>select * from t1;
+----+------+------+------+--------------+
| id | key1 | key2 | key3 | common_field |
+----+------+------+------+--------------+
|  1 | 1    |    1 | 1    | 1            |
|  2 | 1    |    1 | 1    | 1            |
+----+------+------+------+--------------+
2 rows in set (0.00 sec)

root@localhost [db1]>select * from t2;
+----+------+------+------+--------------+
| id | key1 | key2 | key3 | common_field |
+----+------+------+------+--------------+
|  1 | 1    |    1 | 1    | 1            |
|  2 | 1    |    1 | 1    | 1            |
+----+------+------+------+--------------+
2 rows in set (0.00 sec)


root@localhost [db1]> SELECT * FROM t1  WHERE key1 IN (SELECT common_field FROM t2 WHERE key3 = '1');
+----+------+------+------+--------------+
| id | key1 | key2 | key3 | common_field |
+----+------+------+------+--------------+
|  1 | 1    |    1 | 1    | 1            |
|  2 | 1    |    1 | 1    | 1            |
+----+------+------+------+--------------+
2 rows in set (0.00 sec)


root@localhost [db1]>SELECT t1.* FROM t1 INNER JOIN t2 ON t1.key1 = t2.common_field WHERE t2.key3 = '1';
+----+------+------+------+--------------+
| id | key1 | key2 | key3 | common_field |
+----+------+------+------+--------------+
|  1 | 1    |    1 | 1    | 1            |
|  1 | 1    |    1 | 1    | 1            |
|  2 | 1    |    1 | 1    | 1            |
|  2 | 1    |    1 | 1    | 1            |
+----+------+------+------+--------------+
4 rows in set (0.00 sec)

