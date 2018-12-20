## NameNode联邦制
不同的client配置不同的NameNode。
如：华为组的client配置NameNode1,阿里组的client配置NameNode2。
这样华为组只能通过其client向NameNode1提交作业请求，阿里组只能向NameNode2提交作业请求，而DataNode会处理来着所有NameNode 的作业，这样便减少了NameNode的压力

**viewFS**
配置mountTable.xml

为用户提供统一的全局HDFS访问入口，HDFS Federation借鉴Linux提供了client-side mount table，这是通过一层新的文件系统viewfs实现的，它实际上提供了一种映射关系，将一个全局（逻辑）目录映射到某个具体的namenode（物理）目录上，采用这种方式后，core-site.xml配置如下：
```xml
<configuration xmlns:xi="http://www.w3.org/2001/XInclude">
  <xi:include href="mountTable.xml"/>
    <property>
      <name>fs.default.name</name>
      <value>viewfs://ClusterName/</value>
    </property>
</configuration>
```
其中，“ClusterName”是HDFS整个集群的名称，你可以自己定义一个。mountTable.xml配置了全局（逻辑）目录与具体namenode（物理）目录的映射关系，你可以类比linux挂载点来理解。
假设你的集群中有三个namenode，分别是namenode1，namenode2和namenode3，其中，namenode1管理/usr和/tmp两个目录，namenode2管理/projects/foo目录，
namenode3管理/projects/bar目录，则可以创建一个名为“cmt”的client-side mount table，并在mountTable.xml中进行如下配置：
```xml
<configuration>
  <property>
    <name>fs.viewfs.mounttable.cmt.link./user</name>
    <value> hdfs://namenode1:9000/user </value>
  </property>
  <property>
    <name>fs.viewfs.mounttable.cmt.link./tmp</name>
    <value> hdfs:/ namenode1:9000/tmp </value>
  </property>
  <property>
    <name>fs.viewfs.mounttable.cmt.link./projects/foo</name>
    <value> hdfs://namenode2:9000/projects/foo </value>
  </property>
  <property>
    <name>fs.viewfs.mounttable.cmt.link./projects/bar</name>
    <value> hdfs://namenode3:9000/projects/bar</value>
  </property>
</configuration>
```

[reference:dongxicheng.com](http://dongxicheng.org/hadoop-hdfs/hdfs-federation-viewfs/)

