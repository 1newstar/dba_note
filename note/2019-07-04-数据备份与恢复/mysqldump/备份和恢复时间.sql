


备份计划，mysqldump以及xtranbackup的实现原理

在只读的从库, 并且是在业务低峰期进行备份
  大小                   	  备份时间
 压缩前: 2G, 压缩后 190M      1分钟内完成
 压缩前：40G, 压缩后 4.4GB    20分钟内完成
 压缩前: 150G, 压缩后 34G,    30分钟内完成 
 压缩前: 300G, 压缩后 67G,    1个小时内完成
 压缩前: 379G, 压缩后 76G,    1个半小时内完成
 
备份保留两份, 保存多少天内的备份, 主要是看数据量的大小				


备份恢复时间
逻辑导入时间一般是备份时间的3倍以上，还要看大表二级索引的数量
















