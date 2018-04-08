[root@BigData-06 ~]# beeline
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=512M; support was removed in 8.0
Java HotSpot(TM) 64-Bit Server VM warning: Using incremental CMS is deprecated and will likely be removed in a future release
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=512M; support was removed in 8.0
Beeline version 1.1.0-cdh5.12.0 by Apache Hive
beeline> show databases;
No current connection
beeline> connection jdbc:hvie2://BigData-07:1000
. . . .> ;
No current connection
beeline> !connection jdbc:hvie2://BigData-07:1000
Unknown command: connection jdbc:hvie2://BigData-07:1000
beeline> !connection jdbc:hvie2://BigData-07:10000
Unknown command: connection jdbc:hvie2://BigData-07:10000
beeline> !connect jdbc:hvie2://BigData-07:10000
scan complete in 3ms
17/10/25 11:12:22 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: minlog-1.2.jar (No such file or directory)
17/10/25 11:12:22 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: objenesis-1.2.jar (No such file or directory)
17/10/25 11:12:22 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: reflectasm-1.07-shaded.jar (No such file or directory)
17/10/25 11:12:22 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: minlog-1.2.jar (No such file or directory)
17/10/25 11:12:22 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: objenesis-1.2.jar (No such file or directory)
17/10/25 11:12:22 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: reflectasm-1.07-shaded.jar (No such file or directory)
scan complete in 2709ms
No known driver to handle "jdbc:hvie2://BigData-07:10000"
beeline> !connect jdbc:hvie2://BigData-07:10000/
scan complete in 3ms
17/10/25 11:12:29 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: minlog-1.2.jar (No such file or directory)
17/10/25 11:12:29 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: objenesis-1.2.jar (No such file or directory)
17/10/25 11:12:29 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: reflectasm-1.07-shaded.jar (No such file or directory)
17/10/25 11:12:29 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: minlog-1.2.jar (No such file or directory)
17/10/25 11:12:29 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: objenesis-1.2.jar (No such file or directory)
17/10/25 11:12:29 [main]: ERROR beeline.ClassNameCompleter: Fail to parse the class name from the Jar file due to the exception:java.io.FileNotFoundException: reflectasm-1.07-shaded.jar (No such file or directory)
scan complete in 1404ms
No known driver to handle "jdbc:hvie2://BigData-07:10000/"
beeline> !connect jdbc:hive2://BigData-07:10000
Connecting to jdbc:hive2://BigData-07:10000
Enter username for jdbc:hive2://BigData-07:10000: hdfs
Enter password for jdbc:hive2://BigData-07:10000: 
Could not open connection to the HS2 server. Please check the server URI and if the URI is correct, then ask the administrator to check the server status.
Error: Could not open client transport with JDBC Uri: jdbc:hive2://BigData-07:10000: java.net.ConnectException: Connection refused (Connection refused) (state=08S01,code=0)
beeline> !connect jdbc:hive2://BigData-07:10000
Connecting to jdbc:hive2://BigData-07:10000
Enter username for jdbc:hive2://BigData-07:10000: hdfs
Enter password for jdbc:hive2://BigData-07:10000: 
Could not open connection to the HS2 server. Please check the server URI and if the URI is correct, then ask the administrator to check the server status.
Error: Could not open client transport with JDBC Uri: jdbc:hive2://BigData-07:10000: java.net.ConnectException: Connection refused (Connection refused) (state=08S01,code=0)
beeline> !connect jdbc:hive2://BigData-06:10000
Connecting to jdbc:hive2://BigData-06:10000
Enter username for jdbc:hive2://BigData-06:10000: hdfs
Enter password for jdbc:hive2://BigData-06:10000: 
Connected to: Apache Hive (version 1.1.0-cdh5.12.0)
Driver: Hive JDBC (version 1.1.0-cdh5.12.0)
Transaction isolation: TRANSACTION_REPEATABLE_READ
0: jdbc:hive2://BigData-06:10000> show databases;
INFO  : Compiling command(queryId=hive_20171025111313_327aa062-9583-4c5a-b96c-7883d037b51c): show databases
INFO  : Semantic Analysis Completed
INFO  : Returning Hive schema: Schema(fieldSchemas:[FieldSchema(name:database_name, type:string, comment:from deserializer)], properties:null)
INFO  : Completed compiling command(queryId=hive_20171025111313_327aa062-9583-4c5a-b96c-7883d037b51c); Time taken: 0.054 seconds
INFO  : Executing command(queryId=hive_20171025111313_327aa062-9583-4c5a-b96c-7883d037b51c): show databases
INFO  : Starting task [Stage-0:DDL] in serial mode
INFO  : Completed executing command(queryId=hive_20171025111313_327aa062-9583-4c5a-b96c-7883d037b51c); Time taken: 0.033 seconds
INFO  : OK
+----------------+--+
| database_name  |
+----------------+--+
| default        |
| test_etl       |
+----------------+--+
2 rows selected (0.293 seconds)
0: jdbc:hive2://BigData-06:10000> 
