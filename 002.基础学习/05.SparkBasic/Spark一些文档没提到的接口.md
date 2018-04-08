#Spark有一些隐藏的API, 官方没有暴露出来, 下面是一些示例, 可以方便开发

获取job状态

curl http://spark-cluster-ip:6066/v1/submissions/status/driver-20151008145126-0000 
返回样例

```json
 {
  "action" : "SubmissionStatusResponse",
  "driverState" : "FINISHED",
  "serverSparkVersion" : "1.5.0",
  "submissionId" : "driver-20151008145126-0000",
  "success" : true,
  "workerHostPort" : "192.168.3.153:46894",
  "workerId" : "worker-20151007093409-192.168.3.153-46894"
 }
 ```
停止job

curl -X POST http://spark-cluster-ip:6066/v1/submissions/kill/driver-20151008145126-0000 
返回样例
```json
 {
  "action" : "KillSubmissionResponse",
  "message" : "Kill request for driver-20151008145126-0000 submitted",
  "serverSparkVersion" : "1.5.0",
  "submissionId" : "driver-20151008145126-0000",
  "success" : true
 }
```

提交job

curl -X POST http://spark-cluster-ip:6066/v1/submissions/create --header "Content-Type:application/json;charset=UTF-8" --data '{
  "action" : "CreateSubmissionRequest",
  "appArgs" : [ "myAppArgument1" ],
  "appResource" : "file:/myfilepath/spark-job-1.0.jar",
  "clientSparkVersion" : "1.5.0",
  "environmentVariables" : {
    "SPARK_ENV_LOADED" : "1"
  },
  "mainClass" : "com.mycompany.MyJob",
  "sparkProperties" : {
    "spark.jars" : "file:/myfilepath/spark-job-1.0.jar",
    "spark.driver.supervise" : "false",
    "spark.app.name" : "MyJob",
    "spark.eventLog.enabled": "true",
    "spark.submit.deployMode" : "cluster",
    "spark.master" : "spark://spark-cluster-ip:6066"
  }
}'  

返回样例

```scala
{
  "action" : "CreateSubmissionResponse",
  "message" : "Driver successfully submitted as driver-20151008145126-0000",
  "serverSparkVersion" : "1.5.0",
  "submissionId" : "driver-20151008145126-0000",
  "success" : true
}
```