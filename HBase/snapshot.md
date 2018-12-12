## HBase数据迁移
ExportSnapshot
ExportSnapshot使用MapReduce方式来进行表的拷贝。不过和Export不同，ExportSnapshot导出的是表的快照。我们可以使用ExportSnapshot将表的快照数据先导出到从集群，然后再从集群中使用restore_snapshot命令恢复快照，即可实现表在主从集群之间的复制工作

**操作步骤：**
### 建立快照
**源HBase集群**
```vim
$ cd $HBASE_HOME/    
$ bin/hbase shell 
>snapshot 'source_table', 'source_table_snapshot' 
```

### 基于快照克隆一个新表
```vim
clone_snapshot 'source_table_snapshot','new_table'
```
需要注意的是，使用clone_snapshot命令从指定的快照生成新表（克隆）,由于不会产生数据复制，所以最终用到的数据不会是之前的两倍。所以，使用hdfs dfs -du -h查看


### 使用ExportSnapshot命令导出快照数据
使用hbase用户
```vim
su - hbase
$ cd $HBASE_HOME/    
$ bin/hbase org.apache.hadoop.hbase.snapshot.ExportSnapshot -snapshot source_table_snapshot -copy-to hdfs://dist_cluster_namenode:8082/hbase 
```
**限制mapper或者流量个数请加上以下参数：**
```vim
-mapers 10 
-bandwidth 200
```

### 在从集群中恢复快照
```vim
$ cd $HBASE_HOME/    
$ bin/hbase shell 
> restore_snapshot 'source_table_snapshot' 
#查看表：
>list
```

*[reference](http://hbase.apache.org/0.94/book/ops.snapshots.html)*









