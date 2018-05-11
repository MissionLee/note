# spark   error collection

>java.lang.IllegalArgumentException: Can not create a Path from a null string

```note
java.lang.IllegalArgumentException: Can not create a Path from a null string
	at org.apache.hadoop.fs.Path.checkPathArg(Path.java:123)
	at org.apache.hadoop.fs.Path.<init>(Path.java:135)
	at org.apache.hadoop.fs.Path.<init>(Path.java:89)
	at org.apache.spark.internal.io.HadoopMapReduceCommitProtocol.absPathStagingDir(HadoopMapReduceCommitProtocol.scala:58)
	at org.apache.spark.internal.io.HadoopMapReduceCommitProtocol.commitJob(HadoopMapReduceCommitProtocol.scala:132)
	at org.apache.spark.internal.io.SparkHadoopMapReduceWriter$.write(SparkHadoopMapReduceWriter.scala:101)
	at org.apache.spark.rdd.PairRDDFunctions$$anonfun$saveAsNewAPIHadoopDataset$1.apply$mcV$sp(PairRDDFunctions.scala:1085)
	at org.apache.spark.rdd.PairRDDFunctions$$anonfun$saveAsNewAPIHadoopDataset$1.apply(PairRDDFunctions.scala:1085)
	at org.apache.spark.rdd.PairRDDFunctions$$anonfun$saveAsNewAPIHadoopDataset$1.apply(PairRDDFunctions.scala:1085)
	at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:151)
	at org.apache.spark.rdd.RDDOperationScope$.withScope(RDDOperationScope.scala:112)
	at org.apache.spark.rdd.RDD.withScope(RDD.scala:362)
	at org.apache.spark.rdd.PairRDDFunctions.saveAsNewAPIHadoopDataset(PairRDDFunctions.scala:1084)

```
- reason: 

There are OutputFormat implementations which do not need to use `mapreduce.output.fileoutputformat.outputdir` standard hadoop property.

But spark reads this property from the configuration while setting up an OutputCommitter
- solution

This affects both mapred ("mapred.output.dir") and mapreduce ("mapreduce.output.fileoutputformat.outputdir") based OutputFormat's which do not set the properties referenced and is an incompatibility introduced in spark 2.2

Workaround is to explicitly set the property to a dummy value (which is valid and writable by user - say /tmp).

```scala
XXXConfiguration.set("mapreduce.output.fileoutputformat.outputdir", "/tmp")
```

> toDF() is not a member of ...
  - 1. import sqlContext.implicits._ 语句需要放在获取sqlContext对象的语句之后
  - 2. case class People(name : String, age : Int) 的定义需要放在方法的作用域之外（即java的成员变量位置）
  ```scala
  case class Person(name:String,age:Long);
  def main(args: Array[String]): Unit = {
    val conf = new SparkConf().setMaster("local").setAppName("app_hello");
    val sc = new SparkContext(conf);
    /**
      *
      * 利用反射机制推断RDD模式
      * 在利用反射机制推断RDD模式时，需要首先定义一个case class，因为，只有case class才能被Spark隐式地转换为DataFrame。
      * */


    val spk = SparkSession.builder.getOrCreate();
    /***
      * we need to import spk.implicits._ to enable => toDF()
      * or we can not use it !!!!!
      * */
    import spk.implicits._
    val peopleDF = spk.sparkContext.textFile("/home/missingli/IdeaProjects/SparkLearn/src/linziyu/people.txt").map(_.split(","))
      .map(attributes => Person(attributes(0), attributes(1).trim.toInt))
      .toDF();
    //必须注册为临时表才能供下面的查询使用
    //peopleDF.createOrReplaceGlobalTempView("people")
    //peopleDF.registerTempTable("people")
    peopleDF.createOrReplaceTempView("people")
    val personRDD = spk.sql("select name,age from people where age > 0")
    personRDD.map(psr => "name:"+psr(0)+","+"age:"+psr(1)).show() // get the value as an array
  ```

>org.apache.spark.sql.AnalysisException:Table or view not found
```note
这个问题，代码和上一个问题的相同
```
- peopleDF.createOrReplaceGlobalTempView("people")   错误
- peopleDF.registerTempTable("people") 正确
- peopleDF.createOrReplaceTempView("people") 正确

>ERROR SparkContext: Error initializing SparkContext.
java.net.BindException: Cannot assign requested address: Service 'sparkDriver' failed after 16 retries (on a random free port)! Consider explicitly setting the appropriate binding address for the service 'sparkDriver' (for example spark.driver.bindAddress for SparkDriver) to the correct binding address.

- solution from the network
  - add export SPARK_LOCAL_IP="127.0.0.1" to spark-env.sh
  - 实际上，这个地方并没有很严重的影响我的程序（因为我这边的spark就是简单的单机设置）
- 本机上的一些处理
  - 1. export SPARK_LOCAL_IP="127.0.0.1" 这句加入到 spark-env.sh 
    - 实际上 这个 只是影响到了一点点内容， 启动spark-shell的时候 不再题诗 spark-local-ip 没有设置的问题
  - 真正的处理 ！！！！！！！！！！！！
  - 把笔记本的 无线网 关闭了！！！！！！

> 使用 SparkSession.builder.enableHiveSupport().getOrCreate() 进行hive查询

  - 因为没有把配置文件放到idea工程里面，所以出现了读不到数据的问题


>可以获取hive表结构，但是无法获取数据，或者提示 输入的 字段不存在

- SparkSession.read.jdbc("hiveserver ulr","table name",configuration) 这个方法，连接hiveserver2 目前只能读取到 Schema 不能读取到数据，beeline 实现这部分内容，应该 是  拿到 Schema之后从 数据路径里面解析的数据
- Same Question https://community.hortonworks.com/questions/134783/spark-with-hive-jdbc-connection.html

> //18/02/06 22:28:46 INFO FileUtils: Creating directory if it doesn't exist: hdfs://localhost:9000/user/hive/warehouse/lms.db/h180206/.hive-staging_hive_2018-02-06_22-28-46_670_6673726976271936601-1
- 情况描述： 在missingli用户中，idea中SparkSession操作 hive出现如上 内容，并且报错： Permission denined 。。。。。。
- 更改 1 ： 把hdfs上面这个文件目录的 所有者 变成 missingli
- hadoop fs -chown -R missingli /user/hive/warehouse/lms.db/h180206
- 更改后 代码正常执行

>18/02/06 23:06:04 INFO SparkSqlParser: Parsing command: insert into lms.h180206 select id,name from htmp
Exception in thread "main" org.apache.spark.sql.AnalysisException: Table or view not found: lms.h180206, the database lms doesn't exsits.; line 1 pos 0

- 情况描述，在一个类里面，创建一个 普通SparkSession 一个 SparkSession.enableHiveSupport 两者名字不同，代码如下：

```scala
  val ss = SparkSession.builder.appName("").master("local").getOrCreate();
  val shive = SparkSession.builder().config("spark.sql.warehouse.dir", "file:///tmp/spark-warehouse").enableHiveSupport().master("local").appName("321").getOrCreate()

```

- 猜想 ：两个语句顺序的影响！！！！ 两者冲突，但是没有报错，不过第一个可能占用了 “配置文件”
  - 1. 把 ss 这一句注释了 => 程序恢复正常
  - 2. 把 shive 这一句注释了 => 程序恢复正常
  - 3. 追加测试1 ： 两个语句颠倒之后，shive相关的代码可以正常运行了，那么 ss如果有相关的代码是否可以正常执行
    - 说明： 使用ss 建立了 和 mariadb的连接，并且读取其中数据，反馈正常
  - 3. 追加测试2 ： 还用原来的顺序（shive相关内容报错的哪个顺序 ），把shive相关代码注释掉之后，ss相关代码，是否能正常执行
    - 可以正常执行

>18/02/07 08:13:24 WARN ipc.Client: Failed to connect to server: bd002/10.1.2.43:8032: retries get failed due to exceeded maximum allowed retries number: 0
java.net.ConnectException: Connection refused

- 这是因为 配置了 Yarn高可用，spark2-shell寻找的yarn处于standby状态，尝试几次之后，取找另外一个节点，这个错误只是一个 `WARN` 最后会找到另外一个ResourceManager

>18/02/07 启动Spark2-shell失败，出现找不到class

- 节点中 spark-evn.sh 文件丢失

>关于在一个程序中的`SparkSession`的相关问题

- 在同一个程序（JVM）中，用 SparkSession.builder获得的实例，实际上，不管获得几次都是同一个，所以只需要创建一次即可，enableHiveSupport之后是对功能的增强，不影响正常功能使用

>关于SparkSQL 笛卡尔乘积查询的相关探索

- 情景1：

```scala
df.createOrReplaceTempView("table1");
    sql("select * from table1").show();
/**
+----------+---------+
|     uname|      pwd|
+----------+---------+
|limingshun|shunzhiai|
| missingli|        1|
| missingli|        1|
| missingli|        1|
| missingli|        1|
| missingli|        1|
| missingli|        1|
|       msl|   newpwd|
|     spark|      123|
|    hadoop|      456|
|     spark|      123|
|    hadoop|      456|
|     spark|      123|
|    hadoop|      456|
|     spark|      123|
|    hadoop|      456|
+----------+---------+
*/ 
```

- 情景2 （三种情况，类似）

```scala
    df.createOrReplaceTempView("table1");
    sql("select * from table1 a,table1 b").show()//报错
    sql("select * from table1 a join table1 b on 1").show()//报错
    sql("select * from table1 a join table1 b on true").show()//报错
    /**
    Exception in thread "main" org.apache.spark.sql.AnalysisException: Detected cartesian product for INNER join between logical plans
Relation[uname#0,pwd#1] JDBCRelation(user) [numPartitions=1]
and
Relation[uname#6,pwd#7] JDBCRelation(user) [numPartitions=1]
Join condition is missing or trivial.
    */
```

- 情景3
```scala
df.createOrReplaceTempView("table1");
    sql("select * from table1 a join table1 b on a.uname <> b.uname").show()//成功
/**
+----------+---------+----------+---------+
|     uname|      pwd|     uname|      pwd|
+----------+---------+----------+---------+
|limingshun|shunzhiai| missingli|        1|
|limingshun|shunzhiai| missingli|        1|
|limingshun|shunzhiai| missingli|        1|
|limingshun|shunzhiai| missingli|        1|
|limingshun|shunzhiai| missingli|        1|
|limingshun|shunzhiai| missingli|        1|
|limingshun|shunzhiai|       msl|   newpwd|
|limingshun|shunzhiai|     spark|      123|
|limingshun|shunzhiai|    hadoop|      456|
|limingshun|shunzhiai|     spark|      123|
|limingshun|shunzhiai|    hadoop|      456|
|limingshun|shunzhiai|     spark|      123|
|limingshun|shunzhiai|    hadoop|      456|
|limingshun|shunzhiai|     spark|      123|
|limingshun|shunzhiai|    hadoop|      456|
| missingli|        1|limingshun|shunzhiai|
| missingli|        1|       msl|   newpwd|
| missingli|        1|     spark|      123|
| missingli|        1|    hadoop|      456|
| missingli|        1|     spark|      123|
+----------+---------+----------+---------+
*/
```

- 情景4（成功）
```scala
    df.createOrReplaceTempView("table1");
    sql("select * from table1 a cross join table1 b ").show()
```


>Exception in thread "main" org.apache.spark.SparkException: Only one SparkContext may be running in this JVM (see SPARK-2243). To ignore this error, set spark.driver.allowMultipleContexts = true. The currently running SparkContext was created at:
org.apache.spark.sql.SparkSession$Builder.getOrCreate(SparkSession.scala:901)

```scala
// 报错时候的代码顺序
    var conf = new SparkConf().setAppName("").setMaster("local");                               
    var ss = SparkSession.builder().master("local").appName("123").getOrCreate(); 
    val ssc = new SparkContext(conf) 
    var sc = ss.sparkContext;                    
    println(ssc)                                                                  
    println(sc)                                                                   
// 正确时候的代码顺序
    var conf = new SparkConf().setAppName("").setMaster("local");
    val ssc = new SparkContext(conf);
    var ss = SparkSession.builder().master("local").appName("123").getOrCreate();
    var sc = ss.sparkContext;
    println(ssc)
    println(sc)
    //正确时候打印出来的内容
    //org.apache.spark.SparkContext@dc79225
    //org.apache.spark.SparkContext@dc79225
// 我的分析：
  /**
  *首先看一下 SparkContext的源码（部分）
  *  SparkContext 本身有伴生类/伴生对象 
  */
  // If true, log warnings instead of throwing exceptions when multiple SparkContexts are active
  private val allowMultipleContexts: Boolean =
    config.getBoolean("spark.driver.allowMultipleContexts", false)
    //这里，判断是否允许多个 SparkContext
```

>WARN Hive: Failed to access metastore. This class should not accessed in runtime.
org.apache.hadoop.hive.ql.metadata.HiveException: java.lang.RuntimeException: Unable to instantiate org.apache.hadoop.hive.ql.metadata.SessionHiveMetaStoreClient

碰到这个问题解决方法是这样的

- 1.启动 hdfs
- 2.启动mariadb（hive的metastore）
- 3.启动 hive --service metastore

>生产集群Spark2-submit 问题处理记录

- 首先在idea中可以正常执行的jar包，此时
  - spark2-submit --class newsETL --master yarn-cluster --jars sparkETL.jar
Exception in thread "main" java.lang.IllegalArgumentException: Missing application resource.
	at org.apache.spark.launcher.CommandBuilderUtils.checkArgument(CommandBuilderUtils.java:241)
	at org.apache.spark.launcher.SparkSubmitCommandBuilder.buildSparkSubmitArgs(SparkSubmitCommandBuilder.java:160)
	at org.apache.spark.launcher.SparkSubmitCommandBuilder.buildSparkSubmitCommand(SparkSubmitCommandBuilder.java:274)
	at org.apache.spark.launcher.SparkSubmitCommandBuilder.buildCommand(SparkSubmitCommandBuilder.java:151)
	at org.apache.spark.launcher.Main.main(Main.java:86)
  - 这里实际上有一个错误  --jars 不是提交需要运行的jar包的 ，需要运行的jar包直接把名字写在最后了
  - 看到这个问题后，想先看一下 spark shell的情况
  - spark2-shell 报错：Exception in thread "main" java.lang.NoClassDefFoundError: org/apache/hadoop/fs/FSDataInputStream
    - 找到原因，在 spark-env.sh里面追加：export SPARK_DIST_CLASSPATH=$(hadoop classpath)
  - 再次启动 spark2-shell 出现一堆报错，提示 与 XXX:8032连接失败，这是因为yarn ha，spark寻找的yarn是 standby状态，切换以下旧完成了
  - 至此 spark2-shell 正常
  - 回到 spark2-submit
  - 命令改为 spark2-submit --class newsETL --master yarn  /path/to/sparkETLll.jar
  - 提示了无数次 `找不到提交的这个jar包`
  - 分析： 可能是因为 当前用户用的 hdfs，文件实际上在 /root/.../xx.jar,虽然已经把 这个 jar包 chown给了hdfs，但是实际上spark2-submit还是找不到这个jar，把这个jar 挪到 /opt 目录下面 ，再次执行就正常了