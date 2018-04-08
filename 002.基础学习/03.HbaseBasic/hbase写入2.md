[root@BigData-04 ~]# hbase org.apache.hadoop.hbase.mapreduce.ImportTsv -Dimporttsv.separator="," -Dimporttsv.columns=HBASE_ROW_KEY,id:id0,id:id11,id:id12,id:id13,id:id14,id:id15,id:id16,id:id17,id:id18,id:id19,id:id20,id:id21,id:id22,id:id23,id:id24,id:id25,id:id26,id:id2,id:id35,id:id36,id:id37,id:id38,id:id39,id:id40,id:id41,id:id42,id:id43,id:id44,id:id45,id:id46,id:id47,id:id48,id:id49,id:id50 test03 
Java HotSpot(TM) 64-Bit Server VM warning: Using incremental CMS is deprecated and will likely be removed in a future release
17/10/20 16:40:32 INFO zookeeper.RecoverableZooKeeper: Process identifier=hconnection-0x2a3b5b47 connecting to ZooKeeper ensemble=BigDat
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:zookeeper.version=3.4.5-cdh5.12.0--1, built on 06/29/2017 11:30 GMT
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:host.name=BigData-04
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:java.version=1.8.0_121
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:java.vendor=Oracle Corporation
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:java.home=/usr/java/jdk1.8.0_121/jre
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:java.class.path=`此处省略一大堆jar包的路径`
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:java.io.tmpdir=/tmp
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:java.compiler=<NA>
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:os.name=Linux
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:os.arch=amd64
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:os.version=2.6.32-696.13.2.el6.x86_64
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:user.name=root
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:user.home=/root
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Client environment:user.dir=/root
17/10/20 16:40:32 INFO zookeeper.ZooKeeper: Initiating client connection, connectString=BigData-04:2181,BigData-05:2181,BigData-06:2181 uorum=BigData-04:2181,BigData-05:2181,BigData-06:2181, baseZNode=/hbase
17/10/20 16:40:32 INFO zookeeper.ClientCnxn: Opening socket connection to server BigData-05/10.1.2.46:2181. Will not attempt to authenti
17/10/20 16:40:32 INFO zookeeper.ClientCnxn: Socket connection established, initiating session, client: /10.1.2.45:41312, server: BigDat
17/10/20 16:40:32 INFO zookeeper.ClientCnxn: Session establishment complete on server BigData-05/10.1.2.46:2181, sessionid = 0x25f38d696
17/10/20 16:40:33 INFO Configuration.deprecation: io.bytes.per.checksum is deprecated. Instead, use dfs.bytes-per-checksum
17/10/20 16:40:33 INFO client.ConnectionManager$HConnectionImplementation: Closing zookeeper sessionid=0x25f38d696080037
17/10/20 16:40:34 INFO zookeeper.ZooKeeper: Session: 0x25f38d696080037 closed
17/10/20 16:40:34 INFO zookeeper.ClientCnxn: EventThread shut down
17/10/20 16:40:34 INFO client.RMProxy: Connecting to ResourceManager at BigData-02/10.1.2.43:8032
17/10/20 16:40:34 INFO Configuration.deprecation: io.bytes.per.checksum is deprecated. Instead, use dfs.bytes-per-checksum
17/10/20 16:40:36 INFO input.FileInputFormat: Total input paths to process : 1
17/10/20 16:40:36 INFO mapreduce.JobSubmitter: number of splits:8
17/10/20 16:40:36 INFO Configuration.deprecation: io.bytes.per.checksum is deprecated. Instead, use dfs.bytes-per-checksum
17/10/20 16:40:36 INFO mapreduce.JobSubmitter: Submitting tokens for job: job_1507952754598_0911
17/10/20 16:40:36 INFO impl.YarnClientImpl: Submitted application application_1507952754598_0911
17/10/20 16:40:36 INFO mapreduce.Job: The url to track the job: http://BigData-02:8088/proxy/application_1507952754598_0911/
17/10/20 16:40:36 INFO mapreduce.Job: Running job: job_1507952754598_0911
17/10/20 16:40:43 INFO mapreduce.Job: Job job_1507952754598_0911 running in uber mode : false
17/10/20 16:40:43 INFO mapreduce.Job:  map 0% reduce 0%
17/10/20 16:41:00 INFO mapreduce.Job:  map 1% reduce 0%
17/10/20 16:41:01 INFO mapreduce.Job:  map 2% reduce 0%
17/10/20 16:41:07 INFO mapreduce.Job:  map 3% reduce 0%
17/10/20 16:41:19 INFO mapreduce.Job:  map 4% reduce 0%
17/10/20 16:42:13 INFO mapreduce.Job:  map 5% reduce 0%
17/10/20 16:42:15 INFO mapreduce.Job:  map 6% reduce 0%
17/10/20 16:42:25 INFO mapreduce.Job:  map 7% reduce 0%
17/10/20 16:42:31 INFO mapreduce.Job:  map 8% reduce 0%
17/10/20 16:42:41 INFO mapreduce.Job:  map 9% reduce 0%
17/10/20 16:47:10 INFO mapreduce.Job:  map 10% reduce 0%
17/10/20 16:48:26 INFO mapreduce.Job:  map 11% reduce 0%
17/10/20 16:49:58 INFO mapreduce.Job:  map 12% reduce 0%
17/10/20 16:50:08 INFO mapreduce.Job:  map 13% reduce 0%
17/10/20 16:53:45 INFO mapreduce.Job:  map 14% reduce 0%
17/10/20 16:53:49 INFO mapreduce.Job:  map 15% reduce 0%
17/10/20 16:54:43 INFO mapreduce.Job:  map 16% reduce 0%
17/10/20 16:55:11 INFO mapreduce.Job:  map 17% reduce 0%
17/10/20 16:55:23 INFO mapreduce.Job:  map 18% reduce 0%
17/10/20 16:55:38 INFO mapreduce.Job:  map 19% reduce 0%
17/10/20 16:56:11 INFO mapreduce.Job:  map 20% reduce 0%
17/10/20 16:57:46 INFO mapreduce.Job:  map 21% reduce 0%
17/10/20 16:59:24 INFO mapreduce.Job:  map 22% reduce 0%
17/10/20 17:01:08 INFO mapreduce.Job:  map 23% reduce 0%
17/10/20 17:01:20 INFO mapreduce.Job:  map 24% reduce 0%
17/10/20 17:01:43 INFO mapreduce.Job:  map 25% reduce 0%
17/10/20 17:02:37 INFO mapreduce.Job:  map 26% reduce 0%
17/10/20 17:02:43 INFO mapreduce.Job:  map 27% reduce 0%
17/10/20 17:04:36 INFO mapreduce.Job:  map 28% reduce 0%
17/10/20 17:05:32 INFO mapreduce.Job:  map 29% reduce 0%
17/10/20 17:05:44 INFO mapreduce.Job:  map 30% reduce 0%
17/10/20 17:07:10 INFO mapreduce.Job:  map 31% reduce 0%
17/10/20 17:08:34 INFO mapreduce.Job:  map 32% reduce 0%
17/10/20 17:10:39 INFO mapreduce.Job:  map 33% reduce 0%
17/10/20 17:11:46 INFO mapreduce.Job:  map 34% reduce 0%
17/10/20 17:13:35 INFO mapreduce.Job:  map 35% reduce 0%
17/10/20 17:14:20 INFO mapreduce.Job:  map 36% reduce 0%
17/10/20 17:15:49 INFO mapreduce.Job:  map 37% reduce 0%
17/10/20 17:17:49 INFO mapreduce.Job:  map 38% reduce 0%
17/10/20 17:19:57 INFO mapreduce.Job:  map 39% reduce 0%
17/10/20 17:22:38 INFO mapreduce.Job:  map 40% reduce 0%
17/10/20 17:23:20 INFO mapreduce.Job:  map 41% reduce 0%
17/10/20 17:25:03 INFO mapreduce.Job:  map 42% reduce 0%
17/10/20 17:26:10 INFO mapreduce.Job:  map 43% reduce 0%
17/10/20 17:28:41 INFO mapreduce.Job:  map 44% reduce 0%
17/10/20 17:29:44 INFO mapreduce.Job:  map 45% reduce 0%
17/10/20 17:32:15 INFO mapreduce.Job:  map 46% reduce 0%
17/10/20 17:33:44 INFO mapreduce.Job:  map 47% reduce 0%
17/10/20 17:35:45 INFO mapreduce.Job:  map 48% reduce 0%
17/10/20 17:36:43 INFO mapreduce.Job:  map 49% reduce 0%
17/10/20 17:37:37 INFO mapreduce.Job:  map 50% reduce 0%
17/10/20 17:39:10 INFO mapreduce.Job:  map 51% reduce 0%
17/10/20 17:41:23 INFO mapreduce.Job:  map 52% reduce 0%
17/10/20 17:42:40 INFO mapreduce.Job:  map 53% reduce 0%
17/10/20 17:43:05 INFO mapreduce.Job:  map 54% reduce 0%
17/10/20 17:44:50 INFO mapreduce.Job:  map 55% reduce 0%
17/10/20 17:46:24 INFO mapreduce.Job:  map 56% reduce 0%
17/10/20 17:47:56 INFO mapreduce.Job:  map 57% reduce 0%
17/10/20 17:49:11 INFO mapreduce.Job:  map 58% reduce 0%
17/10/20 17:51:41 INFO mapreduce.Job:  map 59% reduce 0%
17/10/20 17:54:19 INFO mapreduce.Job:  map 60% reduce 0%
17/10/20 17:55:44 INFO mapreduce.Job:  map 61% reduce 0%
17/10/20 17:57:49 INFO mapreduce.Job:  map 62% reduce 0%
17/10/20 17:59:00 INFO mapreduce.Job:  map 63% reduce 0%
17/10/20 18:00:20 INFO mapreduce.Job:  map 64% reduce 0%
17/10/20 18:01:00 INFO mapreduce.Job:  map 65% reduce 0%
17/10/20 18:02:07 INFO mapreduce.Job:  map 66% reduce 0%
17/10/20 18:03:03 INFO mapreduce.Job:  map 67% reduce 0%
17/10/20 18:03:44 INFO mapreduce.Job:  map 68% reduce 0%
17/10/20 18:03:50 INFO mapreduce.Job:  map 69% reduce 0%
17/10/20 18:04:00 INFO mapreduce.Job:  map 70% reduce 0%
17/10/20 18:04:10 INFO mapreduce.Job:  map 71% reduce 0%
17/10/20 18:04:42 INFO mapreduce.Job:  map 72% reduce 0%
17/10/20 18:05:25 INFO mapreduce.Job:  map 73% reduce 0%
17/10/20 18:05:44 INFO mapreduce.Job:  map 74% reduce 0%
17/10/20 18:05:50 INFO mapreduce.Job:  map 75% reduce 0%
17/10/20 18:06:06 INFO mapreduce.Job:  map 76% reduce 0%
17/10/20 18:06:32 INFO mapreduce.Job:  map 77% reduce 0%
17/10/20 18:07:09 INFO mapreduce.Job:  map 78% reduce 0%
17/10/20 18:07:30 INFO mapreduce.Job:  map 79% reduce 0%
17/10/20 18:07:39 INFO mapreduce.Job:  map 80% reduce 0%
17/10/20 18:07:46 INFO mapreduce.Job:  map 81% reduce 0%
17/10/20 18:08:43 INFO mapreduce.Job:  map 82% reduce 0%
17/10/20 18:08:48 INFO mapreduce.Job:  map 83% reduce 0%
17/10/20 18:09:02 INFO mapreduce.Job:  map 84% reduce 0%
17/10/20 18:09:19 INFO mapreduce.Job:  map 85% reduce 0%
17/10/20 18:10:03 INFO mapreduce.Job:  map 86% reduce 0%
17/10/20 18:10:10 INFO mapreduce.Job:  map 87% reduce 0%
17/10/20 18:10:21 INFO mapreduce.Job:  map 88% reduce 0%
17/10/20 18:10:28 INFO mapreduce.Job:  map 89% reduce 0%
17/10/20 18:10:37 INFO mapreduce.Job:  map 90% reduce 0%
17/10/20 18:11:10 INFO mapreduce.Job:  map 91% reduce 0%
17/10/20 18:11:32 INFO mapreduce.Job:  map 92% reduce 0%
17/10/20 18:11:40 INFO mapreduce.Job:  map 93% reduce 0%
17/10/20 18:11:55 INFO mapreduce.Job:  map 94% reduce 0%
17/10/20 18:12:04 INFO mapreduce.Job:  map 95% reduce 0%
17/10/20 18:12:55 INFO mapreduce.Job:  map 96% reduce 0%
17/10/20 18:13:04 INFO mapreduce.Job:  map 97% reduce 0%
17/10/20 18:13:51 INFO mapreduce.Job:  map 98% reduce 0%
17/10/20 18:14:26 INFO mapreduce.Job:  map 99% reduce 0%
17/10/20 18:15:10 INFO mapreduce.Job:  map 100% reduce 0%
17/10/20 18:15:30 INFO mapreduce.Job: Job job_1507952754598_0911 completed successfully
17/10/20 18:15:30 INFO mapreduce.Job: Counters: 31
	File System Counters
		FILE: Number of bytes read=0
		FILE: Number of bytes written=1301264
		FILE: Number of read operations=0
		FILE: Number of large read operations=0
		FILE: Number of write operations=0
		HDFS: Number of bytes read=988130359
		HDFS: Number of bytes written=0
		HDFS: Number of read operations=16
		HDFS: Number of large read operations=0
		HDFS: Number of write operations=0
	Job Counters 
		Launched map tasks=8
		Data-local map tasks=8
		Total time spent by all maps in occupied slots (ms)=41186535
		Total time spent by all reduces in occupied slots (ms)=0
		Total time spent by all map tasks (ms)=41186535
		Total vcore-milliseconds taken by all map tasks=41186535
		Total megabyte-milliseconds taken by all map tasks=42175011840
	Map-Reduce Framework
		Map input records=6586367
		Map output records=6586367
		Input split bytes=848
		Spilled Records=0
		Failed Shuffles=0
		Merged Map outputs=0
		GC time elapsed (ms)=50305
		CPU time spent (ms)=39741400
		Physical memory (bytes) snapshot=2855567360
		Virtual memory (bytes) snapshot=22554349568
		Total committed heap usage (bytes)=1482162176
	ImportTsv
		Bad Lines=0
	File Input Format Counters 
		Bytes Read=988129511
	File Output Format Counters 
		Bytes Written=0
