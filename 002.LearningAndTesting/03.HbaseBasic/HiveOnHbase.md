hbase(main):003:0> create 'test01','info'


hive中
CREATE EXTERNAL TABLE hbtest01 (rowkey int, id2 int,value int)
    STORED BY 'org.apache.hadoop.hive.hbase.HBaseStorageHandler'
    WITH SERDEPROPERTIES ("hbase.columns.mapping" = ":key,info:id2,info:value")
    TBLPROPERTIES("hbase.table.name" = "test01");

Time taken: 0.21 seconds
    SET hive.hbase.bulk=true;

hive> INSERT OVERWRITE TABLE hbtest01 SELECT id1 as rowkey, id2, value FROM default.test01;
Query ID = root_20171019093838_7536125e-02ac-4740-9987-79bf1bf0d042
Total jobs = 1
Launching Job 1 out of 1
Number of reduce tasks is set to 0 since there's no reduce operator
Starting Job = job_1507952754598_0053, Tracking URL = http://BigData-02:8088/proxy/application_1507952754598_0053/
Kill Command = /opt/cloudera/parcels/CDH-5.12.0-1.cdh5.12.0.p0.29/lib/hadoop/bin/hadoop job  -kill job_1507952754598_0053
Hadoop job information for Stage-0: number of mappers: 1; number of reducers: 0
2017-10-19 09:38:13,970 Stage-0 map = 0%,  reduce = 0%
2017-10-19 09:39:14,938 Stage-0 map = 0%,  reduce = 0%, Cumulative CPU 69.56 sec
2017-10-19 09:39:41,775 Stage-0 map = 100%,  reduce = 0%, Cumulative CPU 101.26 sec
MapReduce Total cumulative CPU time: 1 minutes 41 seconds 260 msec
Ended Job = job_1507952754598_0053
MapReduce Jobs Launched: 
Stage-Stage-0: Map: 1   Cumulative CPU: 101.26 sec   HDFS Read: 116834087 HDFS Write: 0 SUCCESS
Total MapReduce CPU Time Spent: 1 minutes 41 seconds 260 msec
OK
Time taken: 99.98 seconds


hbase(main):006:0> scan 'test01', {LIMIT => 10}
ROW                                      COLUMN+CELL                                                                                                         
 1                                       column=info:id2, timestamp=1508377100137, value=10000                                                               
 1                                       column=info:value, timestamp=1508377100137, value=36                                                                
 10                                      column=info:id2, timestamp=1508377101139, value=10000                                                               
 10                                      column=info:value, timestamp=1508377101139, value=90                                                                
 100                                     column=info:id2, timestamp=1508377107768, value=10000                                                               
 100                                     column=info:value, timestamp=1508377107768, value=64                                                                
 1000                                    column=info:id2, timestamp=1508377180774, value=10000                                                               
 1000                                    column=info:value, timestamp=1508377180774, value=78                                                                
 101                                     column=info:id2, timestamp=1508377107847, value=10000                                                               
 101                                     column=info:value, timestamp=1508377107847, value=32                                                                
 102                                     column=info:id2, timestamp=1508377107908, value=10000                                                               
 102                                     column=info:value, timestamp=1508377107908, value=8                                                                 
 103                                     column=info:id2, timestamp=1508377107988, value=10000                                                               
 103                                     column=info:value, timestamp=1508377107988, value=90                                                                
 104                                     column=info:id2, timestamp=1508377108077, value=10000                                                               
 104                                     column=info:value, timestamp=1508377108077, value=44                                                                
 105                                     column=info:id2, timestamp=1508377108133, value=10000                                                               
 105                                     column=info:value, timestamp=1508377108133, value=63                                                                
 106                                     column=info:id2, timestamp=1508377108216, value=10000                                                               
 106                                     column=info:value, timestamp=1508377108216, value=41                                                                
10 row(s) in 0.2180 seconds
