# 用structured streaming 做一个简单的例子

网络上能找到的例子，都是对 官方文档的简单复制，这里我根据其他例子自己做一个。

数据源： kafka

首先在kafka里面创建一个topic ： missionlee

```scala
// producer  这是 林子雨老师用过的一个例子

import org.apache.kafka.clients.producer.{KafkaProducer, ProducerConfig, ProducerRecord}
import java.util
/**
  *
  */
object KafkaProducerForHelloWorld {
  def main(args: Array[String]): Unit = {
    val Array(brokers,topic,messagesPerSec,wordsPerMessage)=Array("localhost:9092","missionlee","1","1")

    //zookeeper connection
    val props = new util.HashMap[String,Object]()
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,brokers) //
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,"org.apache.kafka.common.serialization.StringSerializer")
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,"org.apache.kafka.common.serialization.StringSerializer")
    val producer = new KafkaProducer[String, String](props)

    //send some messages
    while(true){
      // 创建一个 几行的，每一行是几个数字的字符串
      (1 to messagesPerSec.toInt).foreach { messageNum =>
        val str = (1 to wordsPerMessage.toInt).map(x => scala.util.Random.nextInt(10).toString)
          .mkString(" ")
        //print(str)
        //println()
        // 把这个字符串封装成 一条记录
        val message = new ProducerRecord[String, String](topic, null, str)
        // 发送这条记录
        producer.send(message)
      }
      Thread.sleep(1)  // sleep 的时间 根据需求 调整
    }
  }
}

```

下面是 structured streaming

```scala

import org.apache.spark.sql.SparkSession


/**
  *
  */
object StructuredStreamingHelloWorld {
  def main(args: Array[String]): Unit = {
      val spark = SparkSession
      .builder()
      .appName("StructuredStreamingHelloWorld")
          .master("local")
      .getOrCreate()
    //spark.sparkContext.setLogLevel("error")
    import spark.implicits._
    val lines=spark.readStream.format("kafka")
      .option("kafka.bootstrap.servers","localhost:9092")
      .option("subscribe", "missionlee")
      .load()
    val numbers = lines.selectExpr("CAST(value AS STRING)").as[String].flatMap(_.split(" "))//.map(_.toInt)
    val sum = numbers.groupBy().count()

    val quer = sum.writeStream
      .outputMode("complete")
      .format("console")
      .start()
    quer.awaitTermination()
  }
}

```

错误处理

- 1. 报错kafka相关： classNotFound
  - 没有这个引入，报错上卖弄这个
  - 引入版本不对，报错： java.lang.AbstractMethodError

需要在依赖中加入：

```xml
        <dependency>
            <groupId>org.apache.spark</groupId>
            <artifactId>spark-sql-kafka-0-10_2.11</artifactId>
            <version>2.3.0</version>
        </dependency>
```

- 2. kafka consumer 出现 leader not found
  - 跟以前spark莫名其妙报错一样。本机的名称被映射为 localhost意外的内容出现了这种错误。把网线拔掉，无线关掉之后 service network restart 之后。变回到localhost就好了
  - 应该有其他方法把本机器固定为localhost的，这种方式解决比较合理
  - 一般启动 zookeeper 还有 kafka server ，consumer的时候，指定 ip，不使用localhost可能更好一些

- 3. 这个测试运行之后看不出来关于效率的特点，毕竟spark 2.3宣传可以达到毫秒级别。我还需要在之后改进一下代码，来印证一下官方说法。当然，这些测试都是在我7岁高龄的笔记本上执行的，挺难的。