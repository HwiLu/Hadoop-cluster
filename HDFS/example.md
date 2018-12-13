## 集群自带mapreduce
```vim  
hadoop jar /opt/cloudera/parcels/CDH-5.7.2-1.cdh5.7.2.p0.18/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.6.0-cdh5.7.2.jar \
wordcount /tmp/a.txt /tmp/a.output
```
**指定队列**

```vim
hadoop jar /opt/cloudera/parcels/CDH-5.7.2-1.cdh5.7.2.p0.18/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.6.0-cdh5.7.2.jar wordcount \
-Dmapred.job.queue.name  /tmp/a.txt /tmp/a.output
 ```
 关于jar包位置，视实际环境路径进行更换。
 
 ## benchmark 测试示例1
 
测试集群benchmark测试
```vim
hadoop jar /opt/cloudera/parcels/CDH-5.7.2-1.cdh5.7.2.p0.18/lib/hadoop-mapreduce/hadoop-mapreduce-client-jobclient-2.6.0-cdh5.7.2-tests.jar \
TestDFSIO -write -nrFiles 1000 -size 10B -resFile /tmp/TestDFSIOresult.txt

```
**指定队列运行**

```vim
hadoop jar /opt/cloudera/parcels/CDH-5.7.2-1.cdh5.7.2.p0.18/lib/hadoop-mapreduce/hadoop-mapreduce-examples-2.6.0-cdh5.7.2.jar wordcount \
-Dmapred.job.queue.name=default  
 /tmp/a.txt /tmp/a.output
 ```
