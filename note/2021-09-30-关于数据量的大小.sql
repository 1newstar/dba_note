

从设计层面能够做到冷热数据分离和规避数据过度增长。

	1. 游戏业务，对于一些战绩数据等，我们一般是保留最近3个月的数据，旧数据迁移到历史库中，旧数据的流水信息，实际上在报表中，已经统计出来了。
	(查历史数据相关，有时候可以提前统计出来，比如俱乐部ID、玩家ID来按天统计相关数据。)

	2. 也有一些日志相关的数据，用MongoDB来存储。

	3. 以轻数据量的方式支撑业务。


要有取舍才行。




