#

1. 官网下在 

- 因为Spark适配原因，我在学习的时候，虽然kafka已经出到1.1版本了，不过还是下在的 0.10版本

- 解压后，需要如下几个步骤

- 1.启动配到zookeeper（当然也可以使用其他zookeeper）

- 启动一个 zookeeper 
  - bin/zookeeper-server-start.sh config/zookeeper.properties

- 启动kafka
  - bin/kafka-server-start.sh config/server.properties

- 创建一个topic，并且指定zookeeper
  - bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic dblab

- 查看当前由那些 topic
  - bin/kafka-topics.sh --list --zookeeper localhost:2181 

- 创建指定topic的一个 producer
  - bin/kafka-console-producer.sh --broker-list localhost:9092 --topic dblab

- 创建指定topic的一个 consumer
  - bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic dblab --from-beginning  

# 一个简单的示例程序
```scala
// Producer
object KafkaDBlabProducer {
  def main(args: Array[String]): Unit = {
    val Array(brokers,topic,messagesPerSec,wordsPerMessage)=Array("localhost:9092","wordsender","3","5")

    //zookeeper connection
    val props = new util.HashMap[String,Object]()
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG,brokers) //
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,"org.apache.kafka.common.serialization.StringSerializer")
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG,"org.apache.kafka.common.serialization.StringSerializer")
```
[kafka配置类](./kafka部分源码解读/kafka配置类思路学习.md)

```scala
    val producer = new KafkaProducer[String, String](props)

    //send some messages
    while(true){
        // 创建一个 几行的，每一行是几个数字的字符串
      (1 to messagesPerSec.toInt).foreach { messageNum =>
        val str = (1 to wordsPerMessage.toInt).map(x => scala.util.Random.nextInt(10).toString)
          .mkString(" ")
        print(str)
        println()
        // 把这个字符串封装成 一条记录
        val message = new ProducerRecord[String, String](topic, null, str)
        // 发送这条记录
        producer.send(message)
      }
      Thread.sleep(1000)
    }
  }
}

// Consumer
object KafkaDBlabConsumer {
    // 这里主要是 streaming 封装了 kafka 的 consumer
  def main(args: Array[String]): Unit = {
      // 首先我们需要一个 StreamingContext
    val sc = new SparkConf().setAppName("KafkaWordCount").setMaster("local[2]")
    val ssc = new StreamingContext(sc, Seconds(10))
      // checkpoint 也是必须的
      // ！！！ 为什么我们需要一个 checkpoint！！！
    ssc.checkpoint("file:///home/missingli/IdeaProjects/SparkLearn/Sourcecheckpoint")
    // 这一个是官网是给的例子
    val kafkaParams = Map[String, Object](
      "bootstrap.servers" -> "localhost:9092",
      "key.deserializer" -> classOf[StringDeserializer],
      "value.deserializer" -> classOf[StringDeserializer],
      "group.id" -> "group-1",
      "auto.offset.reset" -> "latest",
      "enable.auto.commit" -> (false: java.lang.Boolean)
    )
    // 这一个，是我根据创建Producer时候学到的那些内容，推测Consumer一定也有对应的配置类-验证过是可行的
    val kafkaParams2 = Map[String, Object](
      ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG -> "localhost:9092",
      ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG -> classOf[StringDeserializer],
      ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG -> classOf[StringDeserializer],
      ConsumerConfig.GROUP_ID_CONFIG -> "group-1",
      ConsumerConfig.AUTO_OFFSET_RESET_CONFIG -> "latest",
      ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG -> (false: java.lang.Boolean)
    )
    val topics = Array("wordsender")
    val stream = KafkaUtils.createDirectStream[String, String](
      ssc,
      PreferConsistent,
      Subscribe[String, String](topics, kafkaParams))
      // 这个 KafkaUtils 找到底层，也是  new KafkaConsumer[K,V](kafkaParams)
    val linesword = stream.map(record=>record.value).flatMap(_.split(" "))
    val pair = linesword.map(x=>(x,1))
    val wordCounts = pair.reduceByKeyAndWindow(_ + _,_ - _,Minutes(2),Seconds(10),2)
    wordCounts.print
    ssc.start()
    ssc.awaitTermination()
  }
}
```