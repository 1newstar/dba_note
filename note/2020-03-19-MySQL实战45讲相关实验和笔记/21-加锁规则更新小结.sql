


1. RR隔离级别加锁规则：
    两个“原则”、两个“优化”和一个“bug”（作为分析加锁的步骤）： By 丁奇
    2.1 两个基本原则：
         a). 原则 1：加锁的基本单位是 next-key lock
                            next-key lock 是前开后闭区间（5, 10]。
         b). 原则 2：普通索引查找，要向右遍历, 遍历过程中被访问到的对象才会加锁(查找过程中访问到的对象才会加锁。)
                            范围查询， 也需要向右遍历，直到找到不满足条件的第一个值为止
    2.2 索引上等值查询的两个优化(锁的退化)：
         c). 优化 1：索引上的等值查询，给唯一索引加锁的时候，next-key lock退化为行锁。                               
                            退化为行锁                          
         d). 优化 2：索引上的等值查询，向右遍历时且如果最后一个值不满足等值条件的时候，next-key lock 会退化为间隙锁。  # 理解了。
                            退化为间隙锁
    2.3 一个bug：
         e). 一个 bug：唯一索引上的范围查询，会访问到不满足条件的第一个值为止。
		 

2. 8.0.18 的优化: 
    1. 主键索引非等值范围查询, 向右遍历, 最后一个值不满足条件的时候, next-key lock 会退化为间隙锁; 不再需要访问到不满足条件的第一个值为止。
        参考案例: 
        4.1.2 主键索引范围锁                                                                                             
        '4.1.4 唯一索引范围非等值查询(不等号条件里的等值查询)--没有order by desc' 或者 '2. 唯一索引范围非等值查询(不等号条件里的等值查询)--没有order by desc'

    2. 优化了一个 bug：唯一索引上的范围查询，不再需要访问到不满足条件的第一个值为止。
        参考案例: 4.1.3 优化了唯一索引范围 bug

3. order by desc 在 5.7版本 和 MySQL8.0.19之前的版本都存在尾点延伸

4. 辅助索引 c<=20 加锁扩大 

5. 通过实验更新加锁规则.
	做实验, 发现规律
	第一次定位属于等值查询?
	唯一索引/普通索引各自的加锁规则:
        等值
        范围
    order by desc 


