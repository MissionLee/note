# Spark Streaming + Kafka Integration Guide (Kafka broker version 0.10.0 or higher)

The Spark Streaming integration for Kafka 0.10 is similar in design to the 0.8 Direct Stream approach. It provides simple parallelism, 1:1 correspondence between Kafka partitions and Spark partitions, and access to offsets and metadata. However, because the newer integration uses the new Kafka consumer API instead of the simple API, `there are notable[显著的] differences in usage`. This version of the integration[整合] is marked as experimental, so the API is potentially subject to change.

>Linking

For Scala/Java applications using SBT/Maven project definitions, link your streaming application with the following artifact (see Linking section in the main programming guide for further information).

```note
groupId = org.apache.spark
artifactId = spark-streaming-kafka-0-10_2.11
version = 2.3.0
```

`Do not` manually[手动] add dependencies on org.apache.kafka artifacts (e.g. kafka-clients). The spark-streaming-kafka-0-10 artifact has the appropriate[适当的] transitive[过渡] dependencies already, and different versions may be incompatible[不相容] in hard to diagnose[诊断] ways.

>Creating a Direct Stream

Note that the namespace for the import includes the version, org.apache.spark.streaming.kafka010

```Scala
import org.apache.kafka.clients.consumer.ConsumerRecord
import org.apache.kafka.common.serialization.StringDeserializer
import org.apache.spark.streaming.kafka010._
import org.apache.spark.streaming.kafka010.LocationStrategies.PreferConsistent
import org.apache.spark.streaming.kafka010.ConsumerStrategies.Subscribe
// kafka 相关配置参数
val kafkaParams = Map[String, Object](
  "bootstrap.servers" -> "localhost:9092,anotherhost:9092",//端口
  "key.deserializer" -> classOf[StringDeserializer],
  "value.deserializer" -> classOf[StringDeserializer],
  "group.id" -> "use_a_separate_group_id_for_each_stream",//
  "auto.offset.reset" -> "latest",
  "enable.auto.commit" -> (false: java.lang.Boolean)//禁自动commit（offset）自己维护居多
)

val topics = Array("topicA", "topicB")
val stream = KafkaUtils.createDirectStream[String, String](
  streamingContext,// context
  PreferConsistent,//位置策略，用来分派kafka和spark中数据的partitions？
  Subscribe[String, String](topics, kafkaParams)//关于kafka的相关配置
)

stream.map(record => (record.key, record.value))
```

```java
import java.util.*;
import org.apache.spark.SparkConf;
import org.apache.spark.TaskContext;
import org.apache.spark.api.java.*;
import org.apache.spark.api.java.function.*;
import org.apache.spark.streaming.api.java.*;
import org.apache.spark.streaming.kafka010.*;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;
import scala.Tuple2;

Map<String, Object> kafkaParams = new HashMap<>();
kafkaParams.put("bootstrap.servers", "localhost:9092,anotherhost:9092");
kafkaParams.put("key.deserializer", StringDeserializer.class);
kafkaParams.put("value.deserializer", StringDeserializer.class);
kafkaParams.put("group.id", "use_a_separate_group_id_for_each_stream");
kafkaParams.put("auto.offset.reset", "latest");
kafkaParams.put("enable.auto.commit", false);

Collection<String> topics = Arrays.asList("topicA", "topicB");

JavaInputDStream<ConsumerRecord<String, String>> stream =
  KafkaUtils.createDirectStream(
    streamingContext,
    LocationStrategies.PreferConsistent(),
    ConsumerStrategies.<String, String>Subscribe(topics, kafkaParams)
  );

stream.mapToPair(record -> new Tuple2<>(record.key(), record.value()));
```
Each item in the stream is a [ConsumerRecord](http://kafka.apache.org/0100/javadoc/org/apache/kafka/clients/consumer/ConsumerRecord.html)

For possible kafkaParams, see Kafka consumer config docs. If your Spark batch duration is larger than the default Kafka heartbeat session timeout (30 seconds), increase heartbeat.interval.ms and session.timeout.ms appropriately. For batches larger than 5 minutes, this will require changing group.max.session.timeout.ms on the broker. Note that the example sets enable.auto.commit to false, for discussion see Storing Offsets below.

>LocationStrategies - 位置策略

The new Kafka consumer API will pre-fetch messages into buffers.`新的Kafka comsumer API 会把messages预取到buffer里面` Therefore it is important for performance reasons that the Spark integration keep cached consumers on executors (rather than recreating them for each batch), and prefer to schedule partitions on the host locations that have the appropriate consumers.因此，出于性能原因，Spark集成将缓存的消费者保存在执行程序上（而不是为每个批次重新创建它们），并且倾向于在具有合适使用者的主机位置上安排分区。

In most cases, you should use `LocationStrategies.PreferConsistent` as shown above. This will distribute partitions `evenly` across available executors. If your executors are on the same hosts as your Kafka brokers, use `PreferBrokers`, which will prefer to schedule partitions on the Kafka leader for that partition. Finally, if you have a significant skew in load among partitions, use PreferFixed. This allows you to specify an explicit mapping of partitions to hosts (any unspecified partitions will use a consistent location).
- 多数情况下，使用LoactionStartegies.PreferConsistent,在各个executors中均匀分配。
- 如果executors和kafka Brokers在同一个节点，可以使用PreferBrokers，优先依据kafka leader分配
- 如果分区负载存在明显差距，可以使用PreferFixed，按照开发者需求，指定分区到主机的映射

The cache for consumers has a default maximum size of 64. If you expect to be handling more than (64 * number of executors) Kafka partitions, you can change this setting via `spark.streaming.kafka.consumer.cache.maxCapacity.`通过改变这个参数，调整consumers缓存的kafka partitions数量。默认最大是64

If you would like to disable the caching for Kafka consumers, you can set `spark.streaming.kafka.consumer.cache.enabled` to false. Disabling the cache may be needed to workaround the problem described in `SPARK-19185`. This property may be removed in later versions of Spark, once `SPARK-19185` is resolved.

The cache is keyed by topicpartition and group.id, so use a separate group.id for each call to createDirectStream.

>ConsumerStrategies

The new Kafka consumer API has a number of different ways to specify topics, some of which require considerable post-object-instantiation setup. ConsumerStrategies provides an abstraction that allows Spark to obtain properly configured consumers even after restart from checkpoint.新的Kafka消费者API有许多不同的方式来指定主题，其中一些需要大量的后对象实例化设置。 ConsumerStrategies提供了一个抽象，允许Spark从检查点重新启动后即可获取正确配置的使用者。

`ConsumerStrategies.Subscribe`, as shown above, allows you to subscribe to `a fixed collection of topics`. `SubscribePattern` allows you to use a regex to specify topics of interest. Note that unlike the 0.8 integration, using Subscribe or SubscribePattern should respond to adding partitions during a running stream. Finally, Assign allows you to specify a fixed collection of partitions. All three strategies have overloaded constructors that allow you to specify the starting offset for a particular partition.
- 一个topic 列表
- 一个匹配正则-在运行中添加分区也会被响应
- 指定一个固定的分区集合


If you have specific consumer setup needs that are not met by the options above, `ConsumerStrategy is a public class that you can extend`.如果以上都不能满足需求，可以自己实现ConsumerStrategy。

>Creating an RDD

If you have a use case that is better suited to batch processing, you can create an RDD for a defined range of offsets.

```Scala
// Import dependencies and create kafka params as in Create Direct Stream above

val offsetRanges = Array(
  // topic, partition, inclusive starting offset, exclusive ending offset
  OffsetRange("test", 0, 0, 100),
  OffsetRange("test", 1, 0, 100)
)

val rdd = KafkaUtils.createRDD[String, String](sparkContext, kafkaParams, offsetRanges, PreferConsistent)
```

```java
// Import dependencies and create kafka params as in Create Direct Stream above

OffsetRange[] offsetRanges = {
  // topic, partition, inclusive starting offset, exclusive ending offset
  OffsetRange.create("test", 0, 0, 100),
  OffsetRange.create("test", 1, 0, 100)
};

JavaRDD<ConsumerRecord<String, String>> rdd = KafkaUtils.createRDD(
  sparkContext,
  kafkaParams,
  offsetRanges,
  LocationStrategies.PreferConsistent()
);
```

Note that you cannot use `PreferBrokers`, because without the stream there is not a driver-side consumer to automatically look up broker metadata for you. Use `PreferFixed` with your own metadata lookups if necessary.

>Obtaining Offsets
```Scala
stream.foreachRDD { rdd =>
  val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges
  rdd.foreachPartition { iter =>
    val o: OffsetRange = offsetRanges(TaskContext.get.partitionId)
    println(s"${o.topic} ${o.partition} ${o.fromOffset} ${o.untilOffset}")
  }
}
```
```java
stream.foreachRDD(rdd -> {
  OffsetRange[] offsetRanges = ((HasOffsetRanges) rdd.rdd()).offsetRanges();
  rdd.foreachPartition(consumerRecords -> {
    OffsetRange o = offsetRanges[TaskContext.get().partitionId()];
    System.out.println(
      o.topic() + " " + o.partition() + " " + o.fromOffset() + " " + o.untilOffset());
  });
});
```

Note that the typecast to `HasOffsetRanges` will only succeed if it is done in the first method called on the result of createDirectStream, not later down a chain of methods. Be aware that the one-to-one mapping between RDD partition and Kafka partition does not remain after any methods that shuffle or repartition, e.g. reduceByKey() or window().

>Storing Offsets - 

Kafka delivery semantics in the case of failure depend on how and when offsets are stored. Spark output operations are at-least-once. So if you want the equivalent of exactly-once semantics, you must either store offsets after an idempotent[幂等的] output, or store offsets in an atomic transaction alongside output. With this integration, you have 3 options, in order of increasing reliability (and code complexity), for how to store offsets.

[Google]失败情况下的卡夫卡交付语义取决于如何以及何时存储偏移量。 火花输出操作至少一次。 因此，如果您想要完全相同的语义，您必须在幂等输出之后存储偏移量，或将偏移量存储在原子事务中并与输出一起存储。 通过这种集成，您可以选择3个选项，以提高可靠性（和代码复杂度），以便如何存储偏移量。

[MissionLee]kafka的传输完整性（？ semantics 语义学）需要由offset的存储方法和存储时机来保证。Spark的输出行为是——至少一次的.所以如果希望确保-有且只由一次。`必须进行一次幂等输出存储一次结果，或者，在输出的时候进行一次事务性offsets存储`。为了提升可靠性，这样集成操作（存储offset）,可以通过下面三种方式达到：

- 1. Checkpoints - 如果enable了Spark Checkpointing, offset会被存储在checkpoint中。
`If you enable Spark checkpointing, offsets will be stored in the checkpoint`. This is easy to enable, but there are drawbacks[缺点]. Your output operation must be idempotent[幂等的], since you will get repeated outputs; transactions are not an option. Furthermore, you cannot recover from a checkpoint if your application code has changed. For planned upgrades, you can mitigate this by running the new code at the same time as the old code (since outputs need to be idempotent anyway, they should not clash). But for unplanned failures that require code changes, you will lose data unless you have another way to identify known good starting offsets.如果器用了checkpointing，offset会被存储在其中。不过由一些缺点。1.输出操作必须是幂等的，因为可能会触发重复输出。（？不是很明白：）交易不是一种选择。。。除此之外，如果 application code改变了，也不能进行恢复。在有计划的升级中，你可以同时执行新的和旧的代码来减轻这个问题（因为输出需要保证幂等性，他们应该没有冲突）。但是有时候有一些意外的错误，我们不得不修改代码，所以除非由其他好的方法存储offset，否则还是可能丢失数据

- 2. Kafka itself -kafka 自身维护
Kafka has an offset commit API that stores offsets in a special Kafka topic. By default, the new consumer will periodically auto-commit offsets. This is almost certainly not what you want, because messages successfully polled by the consumer may not yet have resulted in a Spark output operation, resulting in undefined semantics. This is why the stream example above sets “enable.auto.commit” to false. However, you can commit offsets to Kafka after you know your output has been stored, using the commitAsync API. The benefit as compared to checkpoints is that Kafka is a durable store regardless of changes to your application code. However, Kafka is not transactional, so your outputs must still be idempotent.
kafka自己由存储offset的API，默认情况下，consumer也会周期性的自动存储。但这很难满足需求，因为已经从kafka里面成功拉取的数据，可能还没有在Spark程序中运算结束，这就可能造成undefined semantics（不完全复合）。这就是为什么上面例子中会禁止使用自动提交。但是你可以使用 commitAsync API 在程序执行成功后提交offset。与checkpoint相比较，其好处再与kafka持久存储，不用担心spark代码发生变化。但是kafka不是事务性的，所以输出还必须是幂等的

```Scala
stream.foreachRDD { rdd =>
  val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges

  // some time later, after outputs have completed
  stream.asInstanceOf[CanCommitOffsets].commitAsync(offsetRanges)
}
```

```java
stream.foreachRDD(rdd -> {
  OffsetRange[] offsetRanges = ((HasOffsetRanges) rdd.rdd()).offsetRanges();

  // some time later, after outputs have completed
  ((CanCommitOffsets) stream.inputDStream()).commitAsync(offsetRanges);
});
```
As with HasOffsetRanges, the cast to CanCommitOffsets will only succeed if called on the result of createDirectStream, not after transformations. The commitAsync call is threadsafe, but must occur after outputs if you want meaningful semantics.

- 3. Your own data store - 自行维护 - 比如用mysql
For data stores that support transactions, saving offsets in the same transaction as the results can keep the two in sync, even in failure situations. If you’re careful about detecting repeated or skipped offset ranges, rolling back the transaction prevents duplicated or lost messages from affecting results. This gives the equivalent of exactly-once semantics. It is also possible to use this tactic even for outputs that result from aggregations, which are typically hard to make idempotent.

```Scala
// The details depend on your data store, but the general idea looks like this

// begin from the the offsets committed to the database
val fromOffsets = selectOffsetsFromYourDatabase.map { resultSet =>
  new TopicPartition(resultSet.string("topic"), resultSet.int("partition")) -> resultSet.long("offset")
}.toMap

val stream = KafkaUtils.createDirectStream[String, String](
  streamingContext,
  PreferConsistent,
  Assign[String, String](fromOffsets.keys.toList, kafkaParams, fromOffsets)
)

stream.foreachRDD { rdd =>
  val offsetRanges = rdd.asInstanceOf[HasOffsetRanges].offsetRanges

  val results = yourCalculation(rdd)

  // begin your transaction

  // update results
  // update offsets where the end of existing offsets matches the beginning of this batch of offsets
  // assert that offsets were updated correctly

  // end your transaction
}
```

```java
// The details depend on your data store, but the general idea looks like this

// begin from the the offsets committed to the database
Map<TopicPartition, Long> fromOffsets = new HashMap<>();
for (resultSet : selectOffsetsFromYourDatabase)
  fromOffsets.put(new TopicPartition(resultSet.string("topic"), resultSet.int("partition")), resultSet.long("offset"));
}

JavaInputDStream<ConsumerRecord<String, String>> stream = KafkaUtils.createDirectStream(
  streamingContext,
  LocationStrategies.PreferConsistent(),
  ConsumerStrategies.<String, String>Assign(fromOffsets.keySet(), kafkaParams, fromOffsets)
);

stream.foreachRDD(rdd -> {
  OffsetRange[] offsetRanges = ((HasOffsetRanges) rdd.rdd()).offsetRanges();
  
  Object results = yourCalculation(rdd);

  // begin your transaction

  // update results
  // update offsets where the end of existing offsets matches the beginning of this batch of offsets
  // assert that offsets were updated correctly

  // end your transaction
});
```
>SSL / TLS

The new Kafka consumer supports SSL. To enable it, set kafkaParams appropriately before passing to createDirectStream / createRDD. Note that this only applies to communication between Spark and Kafka brokers; you are still responsible for separately securing Spark inter-node communication.

```Scala

val kafkaParams = Map[String, Object](
  // the usual params, make sure to change the port in bootstrap.servers if 9092 is not TLS
  "security.protocol" -> "SSL",
  "ssl.truststore.location" -> "/some-directory/kafka.client.truststore.jks",
  "ssl.truststore.password" -> "test1234",
  "ssl.keystore.location" -> "/some-directory/kafka.client.keystore.jks",
  "ssl.keystore.password" -> "test1234",
  "ssl.key.password" -> "test1234"
)
```


>Deploying

As with any Spark applications, spark-submit is used to launch your application.

For Scala and Java applications, if you are using SBT or Maven for project management, then package spark-streaming-kafka-0-10_2.11 and its dependencies into the application JAR. Make sure spark-core_2.11 and spark-streaming_2.11 are marked as provided dependencies as those are already present in a Spark installation. Then use spark-submit to launch your application (see [Deploying section](http://spark.apache.org/docs/latest/streaming-programming-guide.html#deploying-applications) in the main programming guide).