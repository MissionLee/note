```scala
object StructuredStreamingHelloWorld {
  def main(args: Array[String]): Unit = {
    val spark = SparkSession
      .builder()
      .appName("StructuredStreamingHelloWorld")
      .master("local")
      .getOrCreate()
    spark.sparkContext.setLogLevel("error")
    import spark.implicits._
    val lines = spark.readStream.format("kafka")
      .option("kafka.bootstrap.servers", "localhost:9092")
      .option("subscribe", "missionlee")
      .load()
    val time = lines.selectExpr("CAST(value AS STRING)") 
    val quer = time.writeStream
      .outputMode("append")
      .format("console")
      .trigger(Trigger.Continuous("5 milliseconds"))
      .start()
    quer.awaitTermination()
  }
}
```

