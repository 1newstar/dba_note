

1. 对表加MDL写锁
2. MDL写锁降级为MDL读锁
3. 把原表的数据拷贝到临时文件中
4. 数据拷贝完成，做数据表的转换操作：用临时文件替换原表的数据文件
5. MDL读锁升级为MDL写锁
6. 释放MDL锁。

