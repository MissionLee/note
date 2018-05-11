# start

- cluster sizing

对于 1 tb 数据， 备份数 3 的情况下，要有 3TB 空间。 然后考虑中间文件和日志文件（30%）

## cluster setup and installation

- installing java
- creating unix user accounts
  - 为不同的hadoop进程开启不同的用户 The	HDFS, MapReduce,	and	YARN	services	are	usually	run	as	separate	users,	named	 hdfs ,	 mapred , and	 yarn ,	respectively.	They	all	belong	to	the	same	 hadoop 	group.
- Installing Hadoop
- configuring ssh 节点胡同
- Formatting the hdfs filesystem `hdfs namenode -format`
- starting and stopping the deamons 开关守护进程（书中推荐用对应的用户，开启这些进程）
  - （hdfs） start-dfs.sh
  - namenode 和 secondary namenode 运行在哪些机器上 ， 可以从hadoop configuration 中找到他们的hostname
    - hdfs getconf -namenodes (测试过了，执行这个命令就返回namenode的hostname)
  - start-dfs.sh 做了下面的事情
    - 在配置文件制定的节点 ，开启 namenode
    - 在 slaves file中列举的所有节点中开启 datanode
    - 如果配了 secondary namenode 那也开启
  - （yarn） start-yarn.sh
    - 在本机开启 RM
    - 在所有从属节点开启 NM
  - 两者的关闭方式：
    - stop-dfs.sh
    - stop-yarn.sh
  - 这些 .sh脚本使用了 hadoop-deamon.sh 或者 yarn-deamon.sh。 不过使用了前面提到的脚本，就不用直接使用 xx-deamon.sh了。但是，如果你需要从其他系统，或者自己写歌脚本 控制集群，那么 xx-deamon.sh 就很好用
  - （mapred） mr -jobhistory-deamon.sh start historyserver
    - mapreduce只有一个 job history server
- 创建用户目录
  - hadoop fs  -mkdir /user/username
  - hadoop fs -chown username:username /user/username
  - !!! 给这个目录设置存储限制
  - hdfs dfsadmin -setSpaceQuota 1t /user/username

## Hadoop Configuration

hadoop相关的配置文件，最重要的 如下

|Filename| Format |Description
|-|-|-
|hadoop-env.sh |Bash	script |Environment	variables	that	are	used	in	the	scripts	to	run	Hadoop 写入hadoop需要的环境变量
|mapred-env.sh |Bash	script |Environment	variables	that	are	used	in	the	scripts	to	run	MapReduce(overrides	variables	set	in	hadoop-env.sh)写入mapreduce需要的环境变量，会覆盖 hadoop-env.sh里面的
|yarn-env.sh |Bash	script |Environment	variables	that	are	used	in	the	scripts	to	run	YARN	(overrides variables	set	in	hadoop-env.sh) 写入yarn需要的环境变量
|core-site.xml |Hadoop configuration XML |Configuration	settings	for	Hadoop	Core,	such	as	I/O	settings	that	are	common to	HDFS,	MapReduce,	and	YARN 设置hadoop core的参数，比如 I/O配置，对hdfs，mr，yarn通用的
|hdfs-site.xml |Hadoop configuration XML |Configuration	settings	for	HDFS	daemons:	the	namenode,	the	secondary namenode,	and	the	datanodes用来配置关于 各个守护进程的参数，包括 namenode，secondary namenode datanodes 这几个
|mapred-site.xml |Hadoop configuration XML |Configuration	settings	for	MapReduce	daemons:	the	job	history	server配置 mapreduce守护进程： job history server
|yarn-site.xml H|adoop configuration XML |Configuration	settings	for	YARN	daemons:	the	resource	manager,	the	web	app proxy	server,	and	the	node	managers YARN守护进程配置，包括 RM，web app proxy server，NM
|slaves |Plain	text |A	list	of	machines	(one	per	line)	that	each	run	a	datanode	and a	node	manager 每行一个hostname（ip也可以），用来运行 datanode 和 node manager的
|hadoop-metrics2.properties |Java	properties |Properties	for	controlling	how	metrics	are	published	in	Hadoop	(see	Metrics and	JMX)
|log4j.properties |Java	properties |Properties	for	system	logfiles,	the	namenode	audit	log,	and	the	task	log	for	the task	JVM	process	(Hadoop	Logs)
|hadoop-policy.xml |Hadoop configuration XML |Configuration	settings	for	access	control	lists	when	running	Hadoop	in	secure mode 安全模式下，ACL配置

### configuration Management 

配置管理

hadoop 没有一个统一的配置管理信息。取而代之的是，所有节点有自己的配置文件，管理员需要匾额哦正文件的同步。

相 Cloudera Manager 或者Apache Ambari 都很好用

如果集群里的机器性能差别很大，用统一配置就不合适了。

### 环境设置

- java
- memory heap size
- system logfiles

### 重要参数 PAGE 291

- hdfs
- yarn
- cpu/memory setting in yarn and mapreduce

### HADOOP 占用的地址和端口 PAGE 297

### 其他参数

## 安全

早期 hadoop没考虑这么多问题。
