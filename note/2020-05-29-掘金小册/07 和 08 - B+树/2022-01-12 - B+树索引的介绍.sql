

双向链表和单向链表

	各个数据页可以组成一个双向链表，而每个数据页中的记录会按照主键值从小到大的顺序组成一个单向链表，每个数据页都会为存储在它里边儿的记录生成一个页目录，
	在通过主键查找某条记录的时候可以在页目录中使用二分法快速定位到对应的槽，然后再遍历该槽对应分组中的记录即可快速找到指定的记录


	主键索引记录是有序存储的，但是记录所在数据页页号并不是连续的，需要双向链表把数据页关联起来。
	数据页之间可以不在物理结构上相连，只要通过双向链表相关联即可。



叶子节点或叶节点
	用户记录其实都存放在B+树的最底层的节点上，这些节点也被称为叶子节点或叶节点
	
非叶子节点或者内节点
	其余用来存放 目录项 的节点称为非叶子节点或者内节点
	
	
根节点
	B+树最上边的那个节点也称为根节点
	
	
聚簇索引

	聚簇索引的两个特点：

		1. 使用记录主键值的大小进行记录和页的排序，这包括三个方面的含义：

			页内的记录是按照主键的大小顺序排成一个单向链表。

			各个存放用户记录的页也是根据页中用户记录的主键大小顺序排成一个双向链表。
				
			存放目录项记录的页分为不同的层次，在同一层次中的页也是根据页中目录项记录的主键大小顺序排成一个双向链表。

			-- 其中各个节点之间的数据页编号并不是连续的。
			
			
		2. B+树的叶子节点存储的是完整的用户记录。

			所谓完整的用户记录，就是指这个记录中存储了所有列的值（包括隐藏列）。
			
		
		在InnoDB存储引擎中，聚簇索引就是数据的存储方式（所有的用户记录都存储在了叶子节点），也就是所谓的索引即数据，数据即索引。
		
		

二级索引
	
	使用记录c2列的大小进行记录和页的排序，这包括三个方面的含义：

		页内的记录是按照c2列的大小顺序排成一个单向链表。

		各个存放用户记录的页也是根据页中记录的c2列大小顺序排成一个双向链表。

		存放目录项记录的页分为不同的层次，在同一层次中的页也是根据页中目录项记录的c2列大小顺序排成一个双向链表。

	B+树的叶子节点存储的并不是完整的用户记录，而只是c2列+主键 这两个列的值。

	目录项记录中不再是 主键值+页号 的搭配，而变成了 c2列+主键值+页号 的搭配。
	
	
	
InnoDB的B+树索引的注意事项
	
	B+树的形成过程是这样的
	
		1. 建表的时候会建B+树索引，由于还没有记录，会为这个索引创建一个根节点页面   -- 验证下。
			每当为某个表创建一个B+树索引（聚簇索引不是人为创建的，默认就有）的时候，都会为这个索引创建一个根节点页面。
			最开始表中没有数据的时候，每个B+树索引对应的根节点中既没有用户记录，也没有目录项记录。
			 
		2. 往根节点写入数据
			随后向表中插入用户记录时，先把用户记录存储到这个根节点中
		
		3. 根节点的16KB数据页用完
			当根节点中的可用空间用完时继续插入记录，此时会将根节点中的所有记录复制到一个新分配的页，比如页a中
			然后对这个新页进行页分裂的操作，得到另一个新页，比如页b。
			这时新插入的记录根据键值（也就是聚簇索引中的主键值，二级索引中对应的索引列的值）的大小就会被分配到页a或者页b中，而根节点便升级为存储目录项记录的页。
		
			-- 根节点16KB的数据页可用空间用完，会往内节点分配
		
			
	根页面万年不动窝
		一个B+树索引的根节点自诞生之日起，便不会再移动。
		这样只要我们对某个表建立一个索引，那么它的根节点的页号便会被记录到某个地方，
		然后凡是InnoDB存储引擎需要用到这个索引的时候，都会从那个固定的地方取出根节点的页号，从而来访问这个索引。
		
	
	
	内节点中目录项记录的唯一性
		
		对于二级索引的内节点的目录项记录的内容实际上是由三个部分构成的：
			索引列的值
			主键值
			页号
		所以，本案例目录项记录中的组成部分： c2列+主键值+页号。
		这样就能保证B+树每一层节点中各条目录项记录除页号外这个字段(c2列+主键值)是唯一的
		
	
	
	
	
	
	
		
		
		
		