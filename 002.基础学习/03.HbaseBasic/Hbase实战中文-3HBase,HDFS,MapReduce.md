# 分布式HBase HDFS MapReduce

`MapReduce`用一种高效的方式离线(批)处理大量数据

- 一个MapReduce例子
  - 延迟与吞吐量
  - 穿行计算吞吐量有限
  - 并行计算提高吞吐量
  - `MapReduce:用分布式计算最大化吞吐量`

Hadoop提供两个主要组件解决分布式计算.
HDFS(Hadoop Distributed File System),给所有计算机提供一个通用的,共享的文件系统,供他们访问数据.解决了把数据配发给执行者和聚合计算结果的痛苦.执行者在HDFS上访问数据,写入结果,其他执行者也能看到.
Hadoop MapReduce完成信息记录工作,切分工作并保证他们成功完成.使用MapReduce,所要编写的只是`计算工作(Do Work/Map)和聚合工作(Aggregate Work/Reduce)`;Hadoop处理其他的一切.
使用Hadoop MapReduce,代码类似:

```java
public class Map extends Mapper<LongWritable,Text,Text,LongWritable>{
  protected void map(LongWritable key,Text Value,Context context){
    //计算工作
  }
}
```

这段代码实现了map任务.函数输入位long类型键和text类型值,输出为text类型见和longwritable类型值.`Text和LongWritable类型`分别是基本数据类型`String和Long`在Hadoop中的类型.

注意,你不用写全部代码,没有数据切片计算,没有跟踪,没有后期线程池清理,`更妙的是,这段代码可以在Hadoop集群的任何地方运行`,Hadoop基于可用资源,逻辑上在整个及群众分配执行角色,确保每台机器得到twits表的一个数据切片.Hadoop确保计算工作没有拖后腿的,即使执行这崩溃.

聚合工作代码也会以类似方式提交给整个集群

```java
public class Reduce extends Reducer<Text,LongWritable,Text,LongWritable>{
  protected void reduce(Text key,Iterable<LongWritable>,vals,Context context){
    //聚合工作
  }
}
```

这就是reduce工作.这个函数收到map输出的[String,Long]键值对,生成新的[String,Long]键值对.
`Hbase提供了TableMapper和TableReducer`类来帮助完这两项任务.

- Hadoop MapReduce 概览

为提供一个普遍适用的,可靠的,容错的分布式计算框架,MapReduce对于如何实现应用程序有一些限制

- 所有计算分解为map/reduce任务来实现.
- 每个任务处理全部输入数据中的一部分
- 主要根据输入数据和输出数据定义任务
- 任务依赖于自己的输入数据,不需要与其他任务通信

每个规则的例外:
以上提到的更像是指导原则而不是规则.MapReduce面向批处理,如果系统为分布式事件流实时处理设计,则会采用不同的方式.
另一方面,许多其他符合这些限制条件的工作负载会广泛使用Hadoop MapReduce.其中一些工作负载是IO密集型,一些是计算密集型.但是MapReduce是面向IO密集型作业而优化的.

MapReduce数据流介绍

- 用Map和Reduce方法编写程序需要改变一下解决问题的思路.(下面是一些摘要)

  - Map阶段,除了以行为单位拆解数据,Hadoop不需要知道其他的.[例如没有按照某个字段分类这种操作的需求]
  - Map的工作把某个文件/某份数据的`行`分离出来,生成键值对
  - `Reduce阶段之前`,做一些信息记录工作,比如希望在Reduce时候按照某个字段分组(分组依据的字段在应当就是Map阶段的`键`).Hadoop称为洗牌阶段(Shuffle Step/把所有同样键的键值对放在一起)和排序阶段(Sort Step/把键压缩,值汇总成`数组`的样式)
  - Reduce阶段,把`数组`中的值`加起来`

- MapReduce内部机制

  - JobTracker进程-应用监管.负责管理系群上运行的MapReduce应用.作业提交给JobTracker来执行,他管理分配工作负载,也负责记录作业的各个部分的裕兴情况,确保重新启动失败的任务.一个Hadoop集群可以同时运行多个MapReduce应用.JobTracker负责监管资源利用率和作业时间表安排等.
  - TaskTracker[Map阶段和Reduce阶段的工作],JobTracker和TaskTracker是主从关系.TaskTracker(通常有多个)是真正的工作进程,单个TaskTracker没有特殊化设置.任何TaskTracker都可以运行任何作业的任何任务.
  - 一般HDFS DataNode和MapReduce TaskTracker一般并列配置在一起,避免网路上的数据传输哦,如果不在同一节点,会选择同一机架.
  - HBase出现后,也采用同样的理念,但是`一般而言HBase不受和标准Hadoop部署有所不同`

后面第十章有关于这些内容的讨论

- 分布式模式的HBase

理论上HBase可以运行在任何分布式文件系统上,只是和Hadoop的集成更加紧密.
HDFS天生是一种可扩展的存储`但是还不足以支持HBase`成为一种低延迟的数据库.这里还需要一些其他因素,你会了解到.`诸如如何访问HBase,键应该如何设计,HBase应该如何配置等`.

- 切分和分配大表

HBase一张表可能有很多行,列.每个表的大小可能有TB/PB,显然不可能在一台机器存放整个表.相反表会切分成小一点的数据单位,然后分配到多台服务器上.`这些小一点的数据单位叫做region`.托管region的服务器叫`RegionServer`.

RegionServer和HDFS DataNode典型情况下并列配置在同一物理硬件上,实际上唯一的要求是`RegionnServer能够访问HDFS`.RegionServer本质上是HDFS的客户端,在上麦呢存储/访问数据.`Master(主)进程分配region给RegionServer`,每个RegionServer一般托管多个region.

因为数据在HDFS上,所有客户端都可以在一个命名空间访问,所有RegionServer都可以访问文件系统里同一个文件,通过DataNode和RegionServer并列配置,你可以利用数据本地处理特点,也就是说,`理论上RegionServer可以把本地DataNode作为主要DataNode进行读写操作`

在这种体系里,如果工作负载主要是随机读写,MapReduce框架都不需要部署.在另一些HBase部署中,MapReduce计算也是工作负载的一部分,那么TackTracker,DataNode和HBase RegionServer可以一起运行.

单个region大小由配置参数`Hbase.max.filesize`决定.当一个region大于该值,他会切分成两个region.

- 如何找到region

HBase中有两个特殊的表`-ROOT-和.META.`,用来查找各种表的region位置在哪里.-ROOT-和.META.像HBase中其他表一样也会切分成region.-ROOT和.META都是特殊表.但是-ROOT-更特殊一些,他永远不会切分超过一个region.

当客户端应用要访问某行时,他先找-ROOT-表,查找到什么地方可以找到负责某行的region.-ROOT-指向.META.标的region,.META.表由入口地址组成,客户端应用始终这个入口地址判断哪个RegionServer托管待查找的region.

- 如何找到-ROOT-表

HBase系统的交互分几个步骤,Zookeeper是入口点,会告诉客户端-ROOT-在哪

- 总结:
  - 1.向Zookeeper找-ROOT-获得-ROOT-入口,
  - 2.从得到的-ROOT-入口(某个RegionServer),询问.META.在哪,获得.META.入口
  - 3.从.META.入口(某个RegionServer),询问哪个region可以找到目标数据?哪个RegionServer为它提供服务?=>获得RegionServer和region
  - 4.向获得的RegionServer请求目标region上的数据

之后有Zookeeper.-ROOT-和.META.的详细

- HBase和MapReduce

MapReduce应用访问HBase有三种方式

- 数据源
- 数据接收
- 共享资源

使用HBase作为数据源

HBase,用Scan类从HBase中去除数据,内部机制中,由Scan定义的范围去除的行,切分并分配给所有服务器.
=>由RegionServer提供服务的region
=>每个region对应一个map任务,这些任务把对应region的键范围作为他们的输入数据切片,并在上面执行扫描.

在MapReduce里,创建示例扫描所有行

```java
Scan scan = new Scan();
scan.addColumn();
```

如同使用行文本文件,使用HBase记录也需要一种模式.从HBase表中读取的作用以[rowkey:scan result]格式接受[k1,v1]键值对.扫描结果和常规HBase API一样.对应类型是ImmutableBytesWritable和Result.`系统提供TableMapper封装了这些袭击,你会使用它作为基类实现Map阶段功能:`

```java
protected void map(
  ImmutableBytesWritable rowkey,
  Result result,
  Context context
){
  //...
}
```

下一步在MapReduce中使用Scan实例.HBase提供了方便的TableMapReduceUtil类来帮助你初始化Job示例:

```java
//这个initTableMapperJob有好些异构
//http://hbase.apache.org/apidocs/org/apache/hadoop/hbase/mapreduce/TableMapReduceUtil.html
TableMapReduceUtil.initTableMapperJob(// Using this before submitting a TableMap job .It will appropriately set up the job
  "twits",
  //table name
  scan,
  // The scan instance with the columns,time reange etc.
  Map.class,
  //The mapper class to user.
  ImmutableBytesWritable.class,
  //The class of the output key.
  Result.class,
  //The class of the output value.
  job
  //the current job to adjust .Make sure the passed job is carrying all nessary HBase configuration
);
```

这一步会配置作业对象,建立HBase特有的输入格式(TableInputFormat).然后设置MapReduce使用Scan示例来读出记录.这一步会出现在Map和Reduce类的实现里.从现在开始,可以像平常一样编写和运行MapReduce应用.

`当执行如上MapReduce作业时,HBase表的每个region会启动一个map任务`.换句话说,map任务是分解的,每个map任务分别读取一个region.JobTracker尽可能围绕region就近安排map任务.

- HBase接受数据

[MapReduce]从HBase读数据写数据是类似的

`reduce任务不一定写入同一台物理机的region上,有可能写入任何一个包含要写入的键的范围的region.

Hbase提供类似工具简化配置过程.

让我们先看一个标准的MapReduce应用的数据接收配置的例子,,聚合器生成了最终要存储的键值对[k3,v3],Hadoop序列化类型(自己制定了的)为Text和LongWritable.
配置输出类型和配置输入类型类似,不同之处在于,[k3,v3]输出类型需要明确定义,不能由OutputFormat默认指定.

```java
Configuration conf = new Configuration();
Job job = new Job(Conf,"TimeSpent");
job.setOutputKeyClass(Text.class);
job.setOutputValueClass(LongWritable.class);
//...
job.setInputFormatClass(TextInputFormat.class);
job.setOutputFormatClass(TextOutputFormat.class);
```

本例中没有指定行号[`后面看到这里如果忘了,查找P91`].相反,TextOutputFormat模式生成用Tab做分隔符的输出文件,第一部分内容是..,饭后是...,写入硬盘是代表两种类型的字符串(String)
Context对象包含数据类型信息.这里定义reduc函数如下:
```java
public void reduce(Text key,Iterable<LongWritable> values,Context context){
  //...
}
```

`当从MapReduce写入Hbase时`,你会再次使用常规HBaseAPI.假定[k3,v3]键值对的类型是一个行键和一个操作HBase的对象.这意味着v3的值可能是put或delete.因为这两种对象类型包括相应的行键,k3的值可以忽略.和使用TableMapper封装细节一样,`TableReducer`也是如此:

```java
protected void reduce(
  ImmutableBytesWritable rowkey,
  Inerable<Put> values,
  Context context
){
  //..上面定义了reducer的 [k2,v2]的输入类型,他们是map认为输出的中间键值对
}
```

最后一步是吧reducer填写到作业配置中.需要使用合适的类型定义目标表.再一次使用`TableMapReduceUtil`,他为你设置`TableOutputFormat`!这里使用系统提供的`IdentityTableReducer`类,因为你不需要在Reduce阶段执行任何计算:

```java
TableMapReduceUtil.initTableReducerJob("users",IdentityTableReducer.class,job);
```

现在作业完全准备好了,你可以像通常一样执行.和map任务从HBase读取数据时不同,一个reduce任务可以不必只对应一个region. reduce任务会按照行键写入负责相应行键的region. 默认情况下,当区分执行者分配中间键给reduce任务时,它不知道region和托管他们的机器,因此不能智能地分配工作给reducer以支持他们写入本地region.此外,根据在reduce任务中的写入逻辑,可能不一定只是写入同一个reducer,可能最终需要写入整个表.

## 使用HBase共享资源

使用MapReduce读取或者写入HBase很方便的.HBase附带了一些预定义的MapReduce作业,你可以研究这些源代码,他们使用MapReduce访问HBase的范例.

`一种常见的例子是支持大型的Map侧联结(map-side join)`.这种情况下,把HBase看做一个建立了索引的数据源,供所有map任务共享访问读取.=>

