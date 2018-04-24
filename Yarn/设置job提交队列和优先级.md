

作业提交到的队列：mapreduce.job.queuename
----
作业优先级：`mapreduce.job.priority`，优先级默认有5个:LOW VERY_LOW NORMAL（默认） HIGH VERY_HIGH

# 1、静态设置
##1.1 Pig版本
```
SET mapreduce.job.queuename root.default;
```
```
SET mapreduce.job.priority HIGH;
```

## 1.2 Hive版本
```
SET mapreduce.job.queuename=root.default;
```
```
SET mapreduce.job.priority=HIGH;
```
## 1.3 MapReduce版本：
```
hadoop jar app.jar -D mapreduce.job.queuename=root.default -D mapreduce.job.priority=HIGH
```
# 2、动态调整
如果是已经在运行中的任务，可以动态调整任务所属队列及其优先级。

## 2.1 调整优先级
hadoop1.0及以下版本：
```
hadoop job -set-priority job_XXXX VERY_HIGH 
```
hadoop2.0及以上版本：
```
yarn application -appId application_XXXXX -updatePriority VERY_HIGH 
```
## 2.2 动态调整队列 
hadoop2.0及以上版本可以通过下面命令 
```
yarn application  -movetoqueue  application_XXXXX  -queue  root.default
```
其中application_XXXXX为yarn applition id，queue后跟的是需要move到的队列。
