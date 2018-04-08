# 生态圈

`HDFS,MapReduce,YARN`三个基本Hadoop组件

- Hadoop 构成
  - ###基础模块###
  - Hadoop 基础功能库:其他模块的通用程序包
  - HDFS:分布式文件系统
  - YARN: 作业调度和资源管理
  - MapReduce:基于YARN的大数据并行处理程序
  - ###扩展模块###
  - Ambari:基于web的工具,用于配置,管理,监控Hadoop集群.支持`HDFS,MapReduce,Hive,HCataLog,HBase,Zookeeper,Oozie,Pig,Sqoop`可以显示集群健康状况,查看程序运行情况
  - Avro:一个数据序列化系统
  - Cassandra:NoSQL多主数据库
  - Chukwa:分布式数据采集系统
  - HBase:分布式数据库
  - Hive:数据仓库基础架构,提供数据汇总和命令行的即席查询
  - Mahout:一个可扩展的机器学习和数据挖掘库
  - Pig:用于并行计算的高级数据流语言和执行框架
  - Spark:处理Hadoop数据的,告诉,通用计算引擎.
  - Tez:一个完整的数据流编程框架,在YARN之上建立,可替代MapReduce
  - Zookeeper:用于分布式应用的高性能协调服务

## HDFS架构

- NameNode
- DataNode
- ####### NameNode启动时的安全模式
- 当NameNode节点启动时,会金融一种称为`安全模式`的特殊状态.安全模式时,不会进行数据块的复制操作,此时会接收来自DataNode的`心跳和块报告`消息.NameNode使用报告判断`数据块是否安全`(是否达到设定的副本数),和`安全数据块的比例`(由dfs.safemode.threshold.pct参数指定),检测正常,30秒后退出安全模式,否则NameNode会复制`不安全的数据块至安全数量`

- ####### 元数据持久化
- NameNode使用叫做`EditLog`的事务日志持久化记录文件系统元数据的每次变化.`NameNode使用本地主机上的`一个操作系统文件存储EditLog.
- 整个文件系统的命名空间,包括数据块和文件的映射关系,文件系统属性等,存储在一个叫做`FsImage`的文件中.FsImage也是NameNode节点的本地操作系统文件
- NameNode在内存中保留一份完整的文件系统命名空间映像,其中包括文件和数据块的映射关系.启动或者达到配置的阈值触发了检查点时,NameNode把FsImage和EditLog从磁盘读取到内存,对内存中的FsImage应用EditLog里的食物,并将新版本的FsImage写回磁盘,然后清除老的EditLog事务条目,因为他们已经持久化到FsImage了.`这个过程叫做检查点`
- 检查点的目的是确认HDFS有一个文件系统元数据的一致性视图,这是通过建立一个文件系统元数据的快照并保存的到FsImage实现的.`尽管可以高效读取FsImage,但把每次FsImage的改变直接写入磁盘效率很低`,代替做法是每次的变更持久化到EditLog中,在检查点期间再把FsImage刷新到磁盘.
- 检查点有两种触发机制`按以秒为单位的时间间隔触发(dfs.namenode.checkpoint.period)`触发,或者`达到文件系统累加的事务值(dfs.namenode.checkpoint.txns)`时触发.
- DataNode把HDFS文件里的数据存储到本地文件系统.DataNode将HDFS的每个数据块存到一个单独的本地文件中,这些文件并不都在一个目录中.DataNode会根据实际情况决定目录中的文件数,并在适当时候建立子目录.本地文件系统不能支持在一个目录里创建太多文件.
- DataNode启动时扫描本地文件系统,生成该节点上与本地文件对应的所有HDFS数据块的列表,上报NameNode

## MapReduce

- 每个MapReduce程序被表示成一个作业,每个作业分成多个任务.程序向框架提交一个MapReduce作业,作业一般会将输入的数据集合分成彼此独立的数据块,然后由map任务以并行方式对数据库处理.
- 框架对map的输出进行排序,之后输入到reduce任务
- MapRedcue作业的输入输出都存储在一个如HDFS的文件系统上.框架调度并监控任务,失败会重新启动
- `当前版本(新版)`,MapReduce使用YARN管理组员,框架的组成变成三个部分:
  - 主节点资源管理器`ResourceManager`
  - 每个从节点上的节点管理器`NodeManager`
  - 每个应用程序对应的`MRAppMaster`
- MapRedcue作业分为四个步骤
  - Split 分割原始数据
  - Map 处理记录
  - Shuffle 对map的输出执行排序和转换
  - Reduce 计算归并

## Yarn

`Yet Another Resource Negotiator`

YARN的基本思想是将资源管理和吊打及监控功能从MapReduce分离出来,用独立进程实现.

- 全局资源管理器`ResourceManager`
- 每个应用有一个应用主管`ApplicationMaster`
- 节点管理器`NodeManager`
- 资源管理器是系统所有资源分配的最终仲裁.节点管理器报告`CPU,内存,磁盘和网络`
- 每个应用的`ApplicationMaster`实际上是框架中一组特定的库,负责从资源管理器协调资源,并和节点管理器一起工作,共同执行和监控任务.
- 资源管理器有两个主要组件:`调度器和应用管理器`
  - 调度器负责给多个正在运行的应用分配资源,不监控跟踪
  - 应用管理器负责接收应用提交的作业,协调执行特定应用所需的资源容器,并重启失败任务
- Capacity调度器
- Fair调度器
- Container:Container是单个节点的内存,CPU核和磁盘等物理资源的集合.单个节点可以有多个Container.`ApplicationMaster可以请求任何Container`来占据最小容量的整数倍资源.每个应用程序从ApplicationMaster开始,本身就是一个Container.一旦启动,就有RM协商更多的Container,运行过程中可以`动态请求或释放`Container.例如Map的时候请求Map Container,结束后释放,并请求更多Reduce Container.
- NodeManager:`NodeManager是DataNode节点上的"工作进程"代理,管理Hadoop集群独立的计算节点`.职责包括与ResourceManager保持通信,管理Container生命周期,监控Container资源使用情况,跟踪节点健康状况,管理日志和不同应用程序的附属服务(auxiliary service)等.
- ApplicationMaster:运行在集群的每个应用程序,都有自己专用的Application master实例,它实际上运行在每个从节点的一个container进程中.周期性向ResourceManager发送心跳,报告自身状态和应用程序使用情况.RM根据调度结果,给某个AM分配一个预留的Container资源租约.