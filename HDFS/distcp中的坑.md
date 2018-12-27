distcp 使用mapreduce的方式将一个集群的数据cp到另外一个集群。用法：

```vim
hadoop distcp  [参数] hdfs://src-cluster/dir/ hdfs://des-cluster/dir
```
**Bug1**

这个问题貌似是distcp的代码bug。

```vim
Caused by: java.io.IOException: Check-sum mismatch between hdfs://hadoop1.tolls.dot.state.fl.us:8020/user/sami/error1.log 
and hdfs://hadoop1.tolls.dot.state.fl.us:8020/user/zhang/.distcp.tmp.attempt_1472051594557_0001_m_000001_0. Source and 
target differ in block-size. Use -pb to preserve block-sizes during copy. Alternatively, skip checksum-checks altogether, 
using -skipCrc. (NOTE: By skipping checksums, one runs the risk of masking data-corruption during file-transfer.)
```
看到这个Bug一般会使用其推荐的解决办法加上`-skipCrc`参数进行解决，不过实践发现，并无此参数，只有`skipcrccheck`参数，且该参数还不能单独使用，需配合
`-update`使用；然而，将`skipcrccheck`和`-update`加上之后，最后cp过来的数据都或被放在同一个目录之下，即原目录结构变了。
最后，是加上`-pb`参数即可解决。

**Bug2**

提示kerberos认证问题

