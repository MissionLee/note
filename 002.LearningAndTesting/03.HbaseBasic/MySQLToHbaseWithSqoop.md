作者：冰封
链接：https://www.zhihu.com/question/60757771/answer/181070757
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

将Mysql迁移到Hbase主要有三种方法：1、Put APIPut API可能是将数据快速导入HBase表的最直接的方法。但是在导入【大量数据】时不建议使用！但是可以作为简单数据迁移的选择，直接写个代码批量处理，开发简单、方便、可控强。2、MapReduce Job推荐使用sqoop，它的底层实现是mapreduce，数据并行导入的，这样无须自己开发代码，过滤条件通过query参数可以实现。Sqoop是一款开源的工具，主要用于在Hadoop(Hive)与传统的数据库(mysql、postgresql...)间进行数据的传递，可以将MySQL中的数据导进到Hadoop的HDFS中，也可以将HDFS的数据导进到Mysql中。参考Index of /docs。采用如下命令：sqoop import    --connect jdbc:mysql://localhost/db    --username root -P    --table mysql_order    --columns "id,name"    --hbase-table hbase_order    --column-family f    --hbase-row-key id    --query "select id,name from mysql_order where..."   -m 13、采用Bulk load装载数据bulk-load的作用是用mapreduce的方式将hdfs上的文件装载到hbase中，对于海量数据装载入hbase非常有用。需要将MySQL的表数据导出为TSV格式（因为后面使用Import TSV工具），还需要确保有一个字段可以表示HBase表行的row key。具体参考参考http://hbase.apache.org/book.html#arch.bulk.load。各有优势，推荐采用sqoop，可以省去比较多工作。当然只要你高兴，你可以采用其他方法，条条道路通罗马。

使用sqoop将MySQL数据库中的数据导入Hbase
前提：安装好 sqoop、hbase。

下载jbdc驱动：mysql-connector-java-5.1.10.jar

将 mysql-connector-java-5.1.10.jar 复制到 /usr/lib/sqoop/lib/ 下

MySQL导入HBase命令：
sqoop import --connect jdbc:mysql://10.10.97.116:3306/rsearch --table researchers --hbase-table A --column-family person --hbase-row-key id --hbase-create-table --username 'root' -P

说明：
--connect jdbc:mysql://10.10.97.116:3306/rsearch 表示远程或者本地 Mysql 服务的URI，3306是Mysql默认监听端口，rsearch是数据库，若是其他数据库，如Oracle,只需修改URI即可。
--table researchers  表示导出rsearch数据库的researchers表。
--hbase-table A  表示在HBase中建立表A。
--column-family person 表示在表A中建立列族person。
--hbase-row-key id  表示表A的row-key是researchers表的id字段。
--hbase-create-table 表示在HBase中建立表。
--username 'root' 表示使用用户root连接Mysql。

注意：

HBase的所有节点必须能够访问MySQL数据库，不然会出现如下错误：
java.sql.SQLException: null,  message from server: "Host '10.10.104.3' is not allowed to connect to this MySQL server"

[plain] view plain copy
在MySQL数据库服务器节点上执行以下命令允许远程机器使用相应用户访问本地数据库服务器：  
[root@gc01vm6 htdocs] # /opt/lampp/bin/mysql  
  
mysql> use mysql;  
Database changed  
mysql> GRANT ALL PRIVILEGES ON rsearch.* TO 'root'@'10.10.104.3' IDENTIFIED BY '' WITH GRANT OPTION;   
mysql> GRANT ALL PRIVILEGES ON rsearch.* TO 'root'@'10.10.104.5' IDENTIFIED BY '' WITH GRANT OPTION;   
mysql> GRANT ALL PRIVILEGES ON rsearch.* TO 'root'@'10.10.104.2' IDENTIFIED BY '' WITH GRANT OPTION;   

这里10.10.104.2，10.10.104.3，10.10.104.5 是HBase节点。

-------------------------------------------------------------------------------------------------


MySQL导入HBase的日志：

[root@gd02 hadoop]# sqoop import --connect jdbc:mysql://10.10.97.116:3306/rsearch --table researchers --hbase-table A --column-family person --hbase-row-key id --hbase-create-table --username 'root' -P
Enter password: 
11/06/29 19:08:00 INFO tool.CodeGenTool: Beginning code generation
11/06/29 19:08:00 INFO manager.MySQLManager: Executing SQL statement: SELECT t.* FROM `researchers` AS t LIMIT 1
11/06/29 19:08:00 INFO manager.MySQLManager: Executing SQL statement: SELECT t.* FROM `researchers` AS t LIMIT 1
11/06/29 19:08:00 INFO orm.CompilationManager: HADOOP_HOME is /usr/lib/hadoop
11/06/29 19:08:00 INFO orm.CompilationManager: Found hadoop core jar at: /usr/lib/hadoop/hadoop-core.jar
Note: /tmp/sqoop-root/compile/d4dd4cb4e1e325fce31ca72c00a5589c/researchers.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.
11/06/29 19:08:02 INFO orm.CompilationManager: Writing jar file: /tmp/sqoop-root/compile/d4dd4cb4e1e325fce31ca72c00a5589c/researchers.jar
11/06/29 19:08:02 WARN manager.MySQLManager: It looks like you are importing from mysql.
11/06/29 19:08:02 WARN manager.MySQLManager: This transfer can be faster! Use the --direct
11/06/29 19:08:02 WARN manager.MySQLManager: option to exercise a MySQL-specific fast path.
11/06/29 19:08:02 INFO manager.MySQLManager: Setting zero DATETIME behavior to convertToNull (mysql)
11/06/29 19:08:02 INFO mapreduce.ImportJobBase: Beginning import of researchers
11/06/29 19:08:02 INFO manager.MySQLManager: Executing SQL statement: SELECT t.* FROM `researchers` AS t LIMIT 1
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:zookeeper.version=3.3.3-cdh3u0--1, built on 03/26/2011 00:21 GMT
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:host.name=gd02
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:java.version=1.6.0_13
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:java.vendor=Sun Microsystems Inc.
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:java.home=/usr/java/jdk1.6.0_13/jre
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:java.class.path=/usr/lib/hadoop/conf:/usr/java/jdk1.6.0_13/lib/tools.jar:/usr/lib/hadoop:/usr/lib/hadoop/hadoop-core-0.20.2-cdh3u0.jar:/usr/lib/hadoop/lib/ant-contrib-1.0b3.jar:/usr/lib/hadoop/lib/aspectjrt-1.6.5.jar:/usr/lib/hadoop/lib/aspectjtools-1.6.5.jar:/usr/lib/hadoop/lib/commons-cli-1.2.jar:/usr/lib/hadoop/lib/commons-codec-1.4.jar:/usr/lib/hadoop/lib/commons-daemon-1.0.1.jar:/usr/lib/hadoop/lib/commons-el-1.0.jar:/usr/lib/hadoop/lib/commons-httpclient-3.0.1.jar:/usr/lib/hadoop/lib/commons-logging-1.0.4.jar:/usr/lib/hadoop/lib/commons-logging-api-1.0.4.jar:/usr/lib/hadoop/lib/commons-net-1.4.1.jar:/usr/lib/hadoop/lib/core-3.1.1.jar:/usr/lib/hadoop/lib/hadoop-fairscheduler-0.20.2-cdh3u0.jar:/usr/lib/hadoop/lib/hsqldb-1.8.0.10.jar:/usr/lib/hadoop/lib/jackson-core-asl-1.5.2.jar:/usr/lib/hadoop/lib/jackson-mapper-asl-1.5.2.jar:/usr/lib/hadoop/lib/jasper-compiler-5.5.12.jar:/usr/lib/hadoop/lib/jasper-runtime-5.5.12.jar:/usr/lib/hadoop/lib/jets3t-0.6.1.jar:/usr/lib/hadoop/lib/jetty-6.1.26.jar:/usr/lib/hadoop/lib/jetty-servlet-tester-6.1.26.jar:/usr/lib/hadoop/lib/jetty-util-6.1.26.jar:/usr/lib/hadoop/lib/jsch-0.1.42.jar:/usr/lib/hadoop/lib/junit-4.5.jar:/usr/lib/hadoop/lib/kfs-0.2.2.jar:/usr/lib/hadoop/lib/log4j-1.2.15.jar:/usr/lib/hadoop/lib/mockito-all-1.8.2.jar:/usr/lib/hadoop/lib/oro-2.0.8.jar:/usr/lib/hadoop/lib/servlet-api-2.5-20081211.jar:/usr/lib/hadoop/lib/servlet-api-2.5-6.1.14.jar:/usr/lib/hadoop/lib/slf4j-api-1.4.3.jar:/usr/lib/hadoop/lib/slf4j-log4j12-1.4.3.jar:/usr/lib/hadoop/lib/xmlenc-0.52.jar:/usr/lib/hadoop/lib/jsp-2.1/jsp-2.1.jar:/usr/lib/hadoop/lib/jsp-2.1/jsp-api-2.1.jar:/usr/lib/sqoop/conf:/usr/lib/hbase/conf::/usr/lib/sqoop/lib/ant-contrib-1.0b3.jar:/usr/lib/sqoop/lib/ant-eclipse-1.0-jvm1.2.jar:/usr/lib/sqoop/lib/commons-io-1.4.jar:/usr/lib/sqoop/lib/hadoop-mrunit-0.20.2-CDH3b2-SNAPSHOT.jar:/usr/lib/sqoop/lib/ivy-2.0.0-rc2.jar:/usr/lib/sqoop/lib/mysql-connector-java-5.1.10.jar:/usr/lib/hbase/hbase-0.90.1-cdh3u0.jar:/usr/lib/hbase/hbase-0.90.1-cdh3u0-tests.jar:/usr/lib/hbase/lib/activation-1.1.jar:/usr/lib/hbase/lib/asm-3.1.jar:/usr/lib/hbase/lib/avro-1.3.3.jar:/usr/lib/hbase/lib/commons-cli-1.2.jar:/usr/lib/hbase/lib/commons-codec-1.4.jar:/usr/lib/hbase/lib/commons-el-1.0.jar:/usr/lib/hbase/lib/commons-httpclient-3.1.jar:/usr/lib/hbase/lib/commons-lang-2.5.jar:/usr/lib/hbase/lib/commons-logging-1.1.1.jar:/usr/lib/hbase/lib/commons-net-1.4.1.jar:/usr/lib/hbase/lib/core-3.1.1.jar:/usr/lib/hbase/lib/guava-r06.jar:/usr/lib/hbase/lib/hadoop-core.jar:/usr/lib/hbase/lib/hbase-0.90.1-cdh3u0.jar:/usr/lib/hbase/lib/jackson-core-asl-1.5.2.jar:/usr/lib/hbase/lib/jackson-jaxrs-1.5.5.jar:/usr/lib/hbase/lib/jackson-mapper-asl-1.5.2.jar:/usr/lib/hbase/lib/jackson-xc-1.5.5.jar:/usr/lib/hbase/lib/jasper-compiler-5.5.23.jar:/usr/lib/hbase/lib/jasper-runtime-5.5.23.jar:/usr/lib/hbase/lib/jaxb-api-2.1.jar:/usr/lib/hbase/lib/jaxb-impl-2.1.12.jar:/usr/lib/hbase/lib/jersey-core-1.4.jar:/usr/lib/hbase/lib/jersey-json-1.4.jar:/usr/lib/hbase/lib/jersey-server-1.4.jar:/usr/lib/hbase/lib/jettison-1.1.jar:/usr/lib/hbase/lib/jetty-6.1.26.jar:/usr/lib/hbase/lib/jetty-util-6.1.26.jar:/usr/lib/hbase/lib/jruby-complete-1.0.3.jar:/usr/lib/hbase/lib/jsp-2.1-6.1.14.jar:/usr/lib/hbase/lib/jsp-api-2.1-6.1.14.jar:/usr/lib/hbase/lib/jsp-api-2.1.jar:/usr/lib/hbase/lib/jsr311-api-1.1.1.jar:/usr/lib/hbase/lib/log4j-1.2.16.jar:/usr/lib/hbase/lib/protobuf-java-2.3.0.jar:/usr/lib/hbase/lib/servlet-api-2.5-6.1.14.jar:/usr/lib/hbase/lib/servlet-api-2.5.jar:/usr/lib/hbase/lib/slf4j-api-1.5.8.jar:/usr/lib/hbase/lib/slf4j-log4j12-1.5.8.jar:/usr/lib/hbase/lib/stax-api-1.0.1.jar:/usr/lib/hbase/lib/thrift-0.2.0.jar:/usr/lib/hbase/lib/xmlenc-0.52.jar:/usr/lib/hbase/lib/zookeeper.jar:/usr/lib/zookeeper/zookeeper-3.3.3-cdh3u0.jar:/usr/lib/zookeeper/zookeeper.jar:/usr/lib/zookeeper/lib/jline-0.9.94.jar:/usr/lib/zookeeper/lib/log4j-1.2.15.jar:/usr/lib/sqoop/sqoop-1.2.0-cdh3u0.jar:/usr/lib/sqoop/sqoop-test-1.2.0-cdh3u0.jar:
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:java.library.path=/usr/java/jdk1.6.0_13/jre/lib/amd64/server:/usr/java/jdk1.6.0_13/jre/lib/amd64:/usr/java/jdk1.6.0_13/jre/../lib/amd64:/usr/java/packages/lib/amd64:/lib:/usr/lib
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:java.io.tmpdir=/tmp
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:java.compiler=<NA>
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:os.name=Linux
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:os.arch=amd64
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:os.version=2.6.18-164.el5
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:user.name=root
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:user.home=/root
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Client environment:user.dir=/home/hadoop
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Initiating client connection, connectString=gd05:2181,gd03:2181,gd02:2181 sessionTimeout=180000 watcher=hconnection
11/06/29 19:08:02 INFO zookeeper.ClientCnxn: Opening socket connection to server gd03/10.10.104.3:2181
11/06/29 19:08:02 INFO zookeeper.ClientCnxn: Socket connection established to gd03/10.10.104.3:2181, initiating session
11/06/29 19:08:02 INFO zookeeper.ClientCnxn: Session establishment complete on server gd03/10.10.104.3:2181, sessionid = 0x130b2e901cd0012, negotiated timeout = 180000
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Initiating client connection, connectString=gd05:2181,gd03:2181,gd02:2181 sessionTimeout=180000 watcher=hconnection
11/06/29 19:08:02 INFO zookeeper.ClientCnxn: Opening socket connection to server gd03/10.10.104.3:2181
11/06/29 19:08:02 INFO zookeeper.ClientCnxn: Socket connection established to gd03/10.10.104.3:2181, initiating session
11/06/29 19:08:02 INFO zookeeper.ClientCnxn: Session establishment complete on server gd03/10.10.104.3:2181, sessionid = 0x130b2e901cd0013, negotiated timeout = 180000
11/06/29 19:08:02 INFO client.HConnectionManager$HConnectionImplementation: Closed zookeeper sessionid=0x130b2e901cd0013
11/06/29 19:08:02 INFO zookeeper.ZooKeeper: Session: 0x130b2e901cd0013 closed
11/06/29 19:08:02 INFO zookeeper.ClientCnxn: EventThread shut down
11/06/29 19:08:02 INFO mapreduce.HBaseImportJob: Creating missing column family person
11/06/29 19:08:02 INFO client.HBaseAdmin: Started disable of A
11/06/29 19:08:03 INFO client.HBaseAdmin: Disabled A
11/06/29 19:08:03 INFO client.HBaseAdmin: Started enable of A
11/06/29 19:08:06 INFO client.HBaseAdmin: Enabled table A
11/06/29 19:08:07 INFO mapred.JobClient: Running job: job_201106212352_0010
11/06/29 19:08:08 INFO mapred.JobClient:  map 0% reduce 0%
11/06/29 19:08:19 INFO mapred.JobClient:  map 40% reduce 0%
11/06/29 19:08:20 INFO mapred.JobClient:  map 80% reduce 0%
11/06/29 19:08:34 INFO mapred.JobClient:  map 100% reduce 0%
11/06/29 19:08:34 INFO mapred.JobClient: Job complete: job_201106212352_0010
11/06/29 19:08:34 INFO mapred.JobClient: Counters: 11
11/06/29 19:08:34 INFO mapred.JobClient:   Job Counters 
11/06/29 19:08:34 INFO mapred.JobClient:     SLOTS_MILLIS_MAPS=82848
11/06/29 19:08:34 INFO mapred.JobClient:     Total time spent by all reduces waiting after reserving slots (ms)=0
11/06/29 19:08:34 INFO mapred.JobClient:     Total time spent by all maps waiting after reserving slots (ms)=0
11/06/29 19:08:34 INFO mapred.JobClient:     Launched map tasks=5
11/06/29 19:08:34 INFO mapred.JobClient:     SLOTS_MILLIS_REDUCES=0
11/06/29 19:08:34 INFO mapred.JobClient:   FileSystemCounters
11/06/29 19:08:34 INFO mapred.JobClient:     HDFS_BYTES_READ=527
11/06/29 19:08:34 INFO mapred.JobClient:     FILE_BYTES_WRITTEN=310685
11/06/29 19:08:34 INFO mapred.JobClient:   Map-Reduce Framework
11/06/29 19:08:34 INFO mapred.JobClient:     Map input records=81868
11/06/29 19:08:34 INFO mapred.JobClient:     Spilled Records=0
11/06/29 19:08:34 INFO mapred.JobClient:     Map output records=81868
11/06/29 19:08:34 INFO mapred.JobClient:     SPLIT_RAW_BYTES=527
11/06/29 19:08:34 INFO mapreduce.ImportJobBase: Transferred 0 bytes in 28.108 seconds (0 bytes/sec)
11/06/29 19:08:34 INFO mapreduce.ImportJobBase: Retrieved 81868 records.

参考资料：

利用sqoop将mysql数据同步到hive手记
http://www.54chen.com/java-ee/sqoop-mysql-to-hive.html
利用Sqoop将数据从数据库导入到HDFS
http://www.cnblogs.com/gpcuster/archive/2011/03/01/1968027.html
Sqoop
http://www.duyifan.com/
MySQL向Hive/HBase的迁移工具
http://www.javabloger.com/article/hadoop-hive-mysql-sqoop.html
官方手册
http://archive.cloudera.com/cdh/3/sqoop/SqoopUserGuide.html

