
## hiveserver2  报错退出， cdh看到了 内存溢出的错误  原本设置50mb  改为 4GB


- 实际原因，之前测试 oozie的时候，启动了一个 5分钟一次的定时任务，任务会

Test of whether a role has encountered unexpected exits

Bad : This role encountered 1 unexpected exit(s) in the previous 5 minute(s).This included 1 exit(s) due to OutOfMemory errors. Critical threshold: any.
Actions
Change Unexpected Exits Thresholds for all roles in HiveServer2 Default Group role group
Change Unexpected Exits Monitoring Period for all roles in HiveServer2 Default Group role group
Change Unexpected Exits Thresholds for this role instance
Change Unexpected Exits Monitoring Period for this role instance
View the log for this role instance at the time of the health test
Advice
This HiveServer2 health test checks that the HiveServer2 has not recently exited unexpectedly. The test returns "Bad" health if the number of unexpected exits exceeds a critical threshold.

For example, if this test is configured with a critical threshold of 1, this test returns "Good" health if there have been no unexpected exits recently. If 1 or more unexpected exits occured recently, this test returns "Bad" health.

The test also indicates whether any of the exits were caused by an OutOfMemory error if the Cloudera Manager Kill When Out of Memory monitoring setting is enabled.

This test can be configured using the Unexpected Exits Thresholds and Unexpected Exits Monitoring Period HiveServer2 monitoring settings.