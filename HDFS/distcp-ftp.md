- ftp --> hdfs
```sh
hdfs dfs –cp [ftp://username:password@hostname/ftp_path] [hdfs:///hdfs_path]
```

优点：简单，提取速度快

缺点：CLI执行不会显示进度

适用场景：适用于小文件的ftp拷贝

- hdfs --> ftp 

```sh
hadoop distcp [ftp://username:password@hostname/ftp_path] [hdfs:///hdfs_path]
```
优点：简单，能显示拷贝进度，并且是分布式提取的，数据比较快。
缺点： 如果拷贝的文件是不断有其他程序写入，会报错，因为该命令最后要对数据进行checksum导致两边不一致，当然，该命令是主要用于集群间拷贝的。
适用场景：大量文件或大文件的拷贝。

